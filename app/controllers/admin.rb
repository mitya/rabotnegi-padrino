Rabotnegi.controller :admin do
  before { admin_required }
  layout 'admin'

  get :index do
    render "admin/dashboard"
  end
end

Rabotnegi.controller :admin_items, map: "admin/items/:collection/" do
  before { admin_required }
  before { @collection = MongoReflector.metadata_for(params[:collection]) }
  layout "admin"

  get :index, map: '/' + @_map do
    @scope = @collection.klass.respond_to?(:query) ? @collection.klass.query(q: params[:q]) : @collection.klass
    @models = @scope.order_by(@collection.list_order).paginate(params[:page], @collection.list_page_size)
    render "admin_items/index"
  end  
  
  get :show, map: ":id" do
    @model = @collection.klass.get(params[:id])
    render "admin_items/show"
  end
  
  get :edit, map: ":id/edit" do
    @model = @collection.klass.get(params[:id])
  end 
  
  put :update, map: ":id" do
    @model = @collection.klass.get(params[:id])
    update_model @model, params[@collection.singular], url(:admin_item, @collection.key, @model)
  end
  
  delete :destroy, map: ":id" do
    @model = @collection.klass.get(params[:id])    
    @model.destroy
    flash.notice = "#{@model} была удалена"
    redirect_to url(:admin_items, @collection.key)
  end
end
