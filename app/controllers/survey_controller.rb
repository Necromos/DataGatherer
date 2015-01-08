class SurveyController < ApplicationController
  def get_personal_data
    @personal_datum = PersonalDatum.new
    @nationalities = ["Afghan","Albanian","Algerian","Andorran","Angolan","Argentinian","Armenian","Australian","Austrian","Azerbaijani","Bahamian","Bahraini","Bangladeshi","Barbadian","Belarusan","Belgian","Belizean","Beninese","Bhutanese","Bolivian","Bosnian","Botswanan","Brazilian","British","Bruneian","Bulgarian","Burkinese","Burmese","Burundian","Cambodian","Cameroonian","Canadian","Cape Verdean","Chadian","Chilean","Chinese","Colombian","Congolese","Costa Rican","Croatian","Cuban","Cypriot","Czech","Danish","Djiboutian","Dominican","Dominican","Ecuadorean","Egyptian","Salvadorean","English","Eritrean","Estonian","Ethiopian","Fijian","Finnish","French","Gabonese","Gambian","Georgian","German","Ghanaian","Greek","Grenadian","Guatemalan","Guinean","Guyanese","Haitian","Dutch","Honduran","Hungarian","Icelandic","Indian","Indonesian","Iranian","Iraqi","Irish","Italian","Jamaican","Japanese","Jordanian","Kazakh","Kenyan","Kuwaiti","Laotian","Latvian","Lebanese","Liberian","Libyan","Lithuanian","Macedonian","Madagascan","Malawian","Malaysian","Maldivian","Malian","Maltese","Mauritanian","Mauritian","Mexican","Moldovan","Monégasque or Monacan","Mongolian","Montenegrin","Moroccan","Mozambican","Namibian","Nepalese","Dutch","New Zealand","Nicaraguan","Nigerien","Nigerian","North Korean","Norwegian","Omani","Pakistani","Panamanian","Guinean","Paraguayan","Peruvian","Philippine","Polish","Portuguese","Qatari","Romanian","Russian","Rwandan","Saudi","Scottish","Senegalese","Serbian","Seychellois","Sierra Leonian","Singaporean","Slovak","Slovenian","Somali","South African","South Korean","Spanish","Sri Lankan","Sudanese","Surinamese","Swazi","Swedish","Swiss","Syrian","Taiwanese","Tadjik","Tanzanian","Thai","Togolese","Trinidadian Tobagan/Tobagonian","Tunisian","Turkish","Turkoman","Tuvaluan","Ugandan","Ukrainian","Emirati","British","US","Uruguayan","Uzbek","Vanuatuan","Venezuelan","Vietnamese","Welsh","Western Samoan","Yemeni","Yugoslav","Zaïrean","Zambian","Zimbabwean"]
    @countries = ["Afghanistan","Albania","Algeria","Andorra","Angola","Argentina","Armenia","Australia","Austria","Azerbaijan","Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgium","Belize","Benin","Bhutan","Bolivia","Bosnia-Herzegovina","Botswana","Brazil","Britain","Brunei","Bulgaria","Burkina","Burma (official nameMyanmar)","Burundi","Cambodia","Cameroon","Canada","Cape Verde Islands","Chad","Chile","China","Colombia","Congo","Costa Rica","Croatia","Cuba","Cyprus","Czech Republic","Denmark","Djibouti","Dominica","Dominican Republic","Ecuador","Egypt","El Salvador","England","Eritrea","Estonia","Ethiopia","Fiji","Finland","France","Gabon","Gambia"," the","Georgia","Germany","Ghana","Greece","Grenada","Guatemala","Guinea","Guyana","Haiti","Holland (alsoNetherlands)","Honduras","Hungary","Iceland","India","Indonesia","Iran","Iraq","Ireland"," Republic of","Italy","Jamaica","Japan","Jordan","Kazakhstan","Kenya","Kuwait","Laos","Latvia","Lebanon","Liberia","Libya","Liechtenstein","Lithuania","Luxembourg","Macedonia","Madagascar","Malawi","Malaysia","Maldives","Mali","Malta","Mauritania","Mauritius","Mexico","Moldova","Monaco","Mongolia","Montenegro","Morocco","Mozambique","Myanmar see Burma","Namibia","Nepal","Netherlands"," the (seeHolland)","New Zealand","Nicaragua","Niger","Nigeria","North Korea","Norway","Oman","Pakistan","Panama","Papua New Guinea","Paraguay","Peru","the Philippines","Poland","Portugal","Qatar","Romania","Russia","Rwanda","Saudi Arabia","Scotland","Senegal","Serbia","Seychelles"," the","Sierra Leone","Singapore","Slovakia","Slovenia","Solomon Islands","Somalia","South Africa","South Korea","Spain","Sri Lanka","Sudan","Suriname","Swaziland","Sweden","Switzerland","Syria","Taiwan","Tajikistan","Tanzania","Thailand","Togo","Trinidad and Tobago","Tunisia","Turkey","Turkmenistan","Tuvalu","Uganda","Ukraine","United Arab Emirates (UAE)","United Kingdom (UK)","United States of America (USA)","Uruguay","Uzbekistan","Vanuatu","Vatican City","Venezuela","Vietnam","Wales","Western Samoa","Yemen","Yugoslavia","Zaire","Zambia","Zimbabwe"]
  end

  def get_self_esteem
    if params[:id]
      @self_esteem = SelfEsteem.new personal_datum_id: params[:id]
    else
      redirect_to :root
    end
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