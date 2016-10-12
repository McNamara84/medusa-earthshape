class CollectorsController < ApplicationController
  before_action :set_collector, only: [:show, :edit, :update, :destroy]

  # GET /collectors
  # GET /collectors.json
  def index
    @collectors = Collector.all
  end

  # GET /collectors/1
  # GET /collectors/1.json
  def show
  end

  # GET /collectors/new
  def new
    @collector = Collector.new
  end

  # GET /collectors/1/edit
  def edit
  end

  # POST /collectors
  # POST /collectors.json
  def create
    @collector = Collector.new(collector_params)

    respond_to do |format|
      if @collector.save
        format.html { redirect_to @collector, notice: 'Collector was successfully created.' }
        format.json { render action: 'show', status: :created, location: @collector }
      else
        format.html { render action: 'new' }
        format.json { render json: @collector.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collectors/1
  # PATCH/PUT /collectors/1.json
  def update
    respond_to do |format|
      if @collector.update(collector_params)
        format.html { redirect_to @collector, notice: 'Collector was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @collector.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collectors/1
  # DELETE /collectors/1.json
  def destroy
    @collector.destroy
    respond_to do |format|
      format.html { redirect_to collectors_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collector
      @collector = Collector.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def collector_params
      params.require(:collector).permit(:name, :affiliation, :stone_id)
    end
end
