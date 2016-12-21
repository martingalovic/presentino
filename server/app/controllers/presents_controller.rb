class PresentsController < ApplicationController
  before_action :authenticate_user!, except: [:api_index, :api_show]

  def index
    query = Present.order('updated_at DESC')
    if params[:query].present?
      query = query.where('label LIKE ?', "%#{params[:query]}%")
    end
    @presents = query.all
  end

  def api_index
    @presents = Present.all
    render json: @presents
  end

  def api_show
    @present = Present.find(params[:id])
    render json: @present
  end

  def new
    @present = Present.new
    @holidays = Holiday.all
  end

  def create
    t = Present.transaction do
      present = Present.create(present_params)
      present.present_stores.create(present_stores_params)
    end
    if t
      redirect_to presents_path
    end
  end

  def edit
    @present = Present.find(params[:id])
    @holidays = Holiday.all
  end

  def update
    present = Present.find(params[:id])
    t = Present.transaction do
      present.update(present_params)
      # Crappy way to do this but I really don't have time to spend applying proper solutions on this project.
      present.present_stores.delete_all()
      present.present_stores.create(present_stores_params)
    end
    if t
      redirect_to presents_path
    end
  end

  def destroy
    Present.destroy(params[:id])
    redirect_to presents_path
  end

  private

  def present_params
    params.permit(:label, :description, :sex, :age_from, :age_to)
  end

  def present_stores_params
    params.permit(present_stores: [:name, :url, :price])[:present_stores]
  end
end
