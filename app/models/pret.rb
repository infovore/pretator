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

  scope :by_proximity, ->(lat,lon) {
    srid = 4326
    order("ST_Distance(stations.latlon, ST_GeomFromText('POINT (#{lon} #{lat})', #{srid}))")
  }

  #def to_geo_json
    #{
      #:type => "Feature",
      #:geometry => {
        #:type => "Point",
        #:coordinates => [lon,lat]
      #},
      #:properties => {
        #:name => name,
        #:is_installed => is_installed,
        #:is_locked => is_locked,
        #:install_date => install_date,
        #:removal_date => removal_date,
        #:is_temporary => is_temporary,
        #:number_bikes => number_bikes,
        #:number_docks => number_docks,
        #:number_empty_docks => number_empty_docks,
      #}
    #}
  #end

  def distance_and_arc_from_lonlat_to_station(origin_lon,origin_lat,offset_bearing=nil)
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
    { :type => "FeatureCollection",
      :features => prets.map {|s| s.to_geo_json}
    }.to_json
  end

  # TODO : nearest open

  # TODO: ingest routinesk
  def self.create_or_update_from_hashie(pret_hashie)
    pret = Pret.find_or_initialize_by(:pret_number => pret_hashie.number.to_i)
    pret.update(

      :name => pret_hashie.details.name,
      :latlon => pret_hashie.details.phone_number,
      :latlon => "POINT(#{pret_hashie.location.longitude} #{pret_hashie.location.latitude})",
      :phone_number => pret_hashie.details.phone_number,
      :seating => pret_hashie.facilities.seating,
      :has_toilets => pret_hashie.facilities.has_toilets.eql?('Yes'),
      :has_wheelchair_access => pret_hashie.facilities.wheelchair_access,
      :has_wifi => pret_hashie.facilities.wifi,
      :address => pret_hashie.location.address,
      :directions => pret_hashie.location.getting_there,
      :pret_number => pret_hashie.number.to_i,
      :opening_hours => pret_hashie.opening_hours
    )
  end
end
