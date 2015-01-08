class SurveyController < ApplicationController
  def get_personal_data
    @personal_datum = PersonalDatum.new
  end

  def get_self_esteem
    @self_esteem = SelfEsteem.new personal_datum_id: params[:id]
  end

  def index
  end

  def thank_you
    if @personal_datum
      redirect_to :action => 'index'
    end
  end

  def create_person
    @personal_datum = PersonalDatum.where(:age => personal_datum_params[:age],
                                          :nationality => personal_datum_params[:nationality],
                                          :race => personal_datum_params[:race],
                                          :living_country => personal_datum_params[:living_country],
                                          :health_issues => personal_datum_params[:health_issues],
                                          :chronic_diseases => personal_datum_params[:chronic_diseases],
                                          :smoker => personal_datum_params[:smoker],
                                          :alcoholic => personal_datum_params[:alcoholic],
                                          :druggy => personal_datum_params[:druggy],
                                          :disabled => personal_datum_params[:disabled]).first_or_create
    if @personal_datum.valid?
      redirect_to :action => 'get_self_esteem', :id => @personal_datum.id
    else
      render :action => :get_personal_data
    end
  end

  def create_self_esteem_for_person
    @self_esteem = SelfEsteem.new(self_esteem_params)
    if @self_esteem.save
      redirect_to :action => 'thank_you'
    else
      render :action => :get_self_esteem
    end
  end

  private

    def set_personal_datum
      @personal_datum = PersonalDatum.find(params[:id])
    end

    def personal_datum_params
      params.require(:personal_datum).permit(:age, :nationality, :race, :living_country, :health_issues, :chronic_diseases, :smoker, :alcoholic, :druggy, :disabled)
    end

    def set_self_esteem
      @self_esteem = SelfEsteem.find(params[:id])
    end

    def self_esteem_params
      params.require(:self_esteem).permit(:personal_datum_id, :alcohol, :tabacco, :drugs, :walking_time_per_day, :jogging_time_per_day, :gym_workout_time_per_day, :wholesome_food_per_day, :junk_food_per_day, :weather, :season, :self_esteem)
    end
end
