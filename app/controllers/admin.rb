Rabotnegi.controller :admin do
  before { admin_required }
  layout 'admin'

  get :index do
    render "admin/dashboard"
  end
end

Rabotnegi.controller :admin_items, map: "admin/:collection/" do 
  before { admin_required }
  before { @collection = Gore::MongoReflector.metadata_for(params[:collection]) }
  layout "admin"

  get :index, "/#{@_map}" do
    @scope = @collection.klass.respond_to?(:query) ? @collection.klass.query(q: params[:q]) : @collection.klass
    @models = @scope.order_by(@collection.list_order).paginate(params[:page], @collection.list_page_size)
    render "admin_items/index"
  end  
  
  get :show, ":id" do
    @model = @collection.klass.get(params[:id])
    render "admin_items/show"
  end
  
  get :edit, "edit/:id", name: :wah do
    @model = @collection.klass.get(params[:id])
    render "admin_items/edit"
  end 
  
  post :update, "update/:id" do
    @model = @collection.klass.get(params[:id])
    update_model @model, params[@collection.singular], url(:admin_item, @collection.key, @model)
  end
  
  post :delete, "delete/:id" do
    @model = @collection.klass.get(params[:id])    
    @model.destroy
    flash.notice = "#{@model} была удалена"
    redirect url(:admin_items, @collection.key)
  end
end
