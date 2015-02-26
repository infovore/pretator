class PretsController < ApplicationController
  protect_from_forgery :except => :nearest
  def index
    @prets = Pret.open
  end

  def nearest
    hash = Pret.nearest_open(params[:lat], params[:lon])

    render :json => hash.to_json(:methods => [:lat,:lon, :distance, :arc]) 
  end
end
