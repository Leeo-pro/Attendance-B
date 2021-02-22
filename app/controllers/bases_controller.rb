class BasesController < ApplicationController
  
  def index_area
    @base = Base.new
    @bases = Base.all
  end
  
  def new
  end
  
  def create
    @base = Base.new(base_params)
    if @base.base_number.nil?
      @base.base_number = Base.maximum(:base_number) +1
    end
    if @base.save
      flash[:success] = "拠点登録完了しました。"
      redirect_to index_area_bases_url
    else
      flash[:danger] = "拠点の登録に失敗しました。"
      redirect_to index_area_bases_url
    end
  end
  
  def edit
    @base = Base.find(params[:id])
  end
  
  def update
    @base = Base.find(params[:id])
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を更新しました。"
      redirect_to index_area_bases_url
    else
      render :edit
    end
  end
  
  def show
  end
  
  def destroy
    @base = Base.find(params[:id])
    @base.destroy
    flash[:success] = "#{@base.base_name}のデータを削除しました。"
    redirect_to index_area_bases_url
  end

private
  def base_params
    params.require(:base).permit(:base_number, :base_name, :base_kind)
  end
end
