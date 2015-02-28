class Pret < ActiveRecord::Base
  attr_accessor :distance_and_arc
  serialize :opening_hours

  set_rgeo_factory_for_column(:latlon,
    RGeo::Geographic.spherical_factory(:srid => 4326))

  delegate :lat, :to => :latlon
  delegate :lon, :to => :latlon

  #scope :active, -> {
    #where(is_installed: true,
          #is_locked: false)
  #}

  scope :open, -> {
    where(has_opened: true)
  }

  scope :by_proximity, ->(lat,lon) {
    srid = 4326
    order("ST_Distance(prets.latlon, ST_GeomFromText('POINT (#{lon} #{lat})', #{srid}))")
  }

  def to_geo_json
    {
      type: "Feature",
      geometry: {
        type: "Point",
        coordinates: [lon,lat]
      },
      properties: {
        name: name,
        phone_number: phone_number,
        seating: seating,
        has_toilets: has_toilets,
        has_wheelchair_access: has_wheelchair_access,
        has_wifi: has_wifi,
        has_opened: has_opened,
        address: address,
        directions: directions,
        pret_number: pret_number
      }
    }
  end

  def distance_and_arc_from_lonlat_to_pret(origin_lon,origin_lat,offset_bearing=nil)
    deg = Pret.connection.select_all("select degrees( ST_Azimuth(ST_Point(#{origin_lon},#{origin_lat}), ST_Point(#{lon},#{lat})))").rows[0][0] # first field of first row

    distance = Pret.connection.select_all("SELECT round(CAST(ST_Distance_Sphere(ST_Point(#{origin_lon},#{origin_lat}), ST_Point(#{lon},#{lat})) As numeric),2) As dist_meters").rows[0][0]

    deg = deg.to_f
    distance = distance.to_f
    if offset_bearing
      offset_bearing = offset_bearing.to_f
    end

    {:distance => distance, :arc => deg, :offset_bearing => offset_bearing}
  end

  # these two methods access the decorated distance and arc
  def distance
    distance_and_arc[:distance]
  end

  def arc
    distance_and_arc[:arc]
  end

  def distance_rounded
    distance.round
  end

  def arc_rounded
    arc.round
  end

  def offset_bearing
    distance_and_arc[:offset_bearing] || 0
  end

  def offset_bearing_rounded
    if offset_bearing
      offset_bearing.round 
    else
      0
    end
  end

  def self.collection_to_feature_collection(prets)
    {
      type: "FeatureCollection",
      features: prets.map(&:to_geo_json)
    }.to_json
  end

  # TODO : nearest open

  def self.nearest_open(lat,lon,heading=nil)
    pret = open.by_proximity(lat,lon).limit(1).first
    # now decorate that with distance, arc from origin, and offset bearing if
    # appropriate
    pret.distance_and_arc = pret.distance_and_arc_from_lonlat_to_pret(lon,lat,heading)
    pret
  end

  def self.create_or_update_from_hashie(pret_hashie)
    pret = Pret.find_or_initialize_by(:pret_number => pret_hashie.number.to_i)
    pret.update(

      :name => pret_hashie.details.name,
      :latlon => "POINT(#{pret_hashie.location.longitude} #{pret_hashie.location.latitude})",
      :phone_number => pret_hashie.details.phone_number,
      :seating => pret_hashie.facilities.seating,
      :has_toilets => pret_hashie.facilities.has_toilets.eql?('Yes'),
      :has_wheelchair_access => pret_hashie.facilities.wheelchair_access,
      :has_wifi => pret_hashie.facilities.wifi,
      :has_opened => pret_hashie.details.has_opened,
      :address => pret_hashie.location.address,
      :directions => pret_hashie.location.getting_there,
      :pret_number => pret_hashie.number.to_i,
      :opening_hours => pret_hashie.opening_hours
    )
  end
end
