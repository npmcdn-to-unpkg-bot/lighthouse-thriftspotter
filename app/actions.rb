# Homepage (Root path)
require 'pry'
require 'bcrypt'
use Rack::MethodOverride
enable :sessions

helpers do
  def logged_in?
    session[:session_token] ? true : false
  end
end

def get_file_name(title, image_name)
  name = title.gsub(/\s+/,'_').downcase
  extension = /\..*/.match(image_name)[0]
  timestamp = Time.now.getutc.to_i.to_s
  "./public/images/#{name}_#{timestamp}#{extension}"
end

def check_password(user, password)
  user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
end

get '/' do
  @items = Item.all.order(created_at: :desc)
  erb :index
end
#
# password_digest, null: false
# session_token

get '/items/new' do
  @item = Item.new(
    title: params[:title],
    description: params[:description],
    image_path: params[:image_path],
    price: params[:price],
    location: params[:location],
    user_id: params[:user_id]
  )
  erb :'items/new'
end

post '/items/new' do
  @item = Item.new(
    title: params[:title],
    description: params[:description],
    price: params[:price],
    image_path: get_file_name(params[:title], params[:image][:filename]),
    location: params[:location],
    user_id: params[:user_id]
  )

  file = params[:image][:tempfile]

  File.open(@item.image_path, 'wb') do |f|
    f.write(file.read)
  end

  if @item.save
    redirect '/'
  else
    redirect 'items/new'
  end
end

get '/items/show' do
  erb :'items/show'
end

get '/users/signup' do
  @user = User.new
  erb :'users/signup'
end

post '/users/signup' do
  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)
  @user = User.new(
    username: params[:username],
    name: params[:name],
    email: params[:email],
    password_salt: password_salt,
    password_hash: password_hash
  )
  if @user.save
    redirect '/users/login'
  else
    erb :'users/signup'
  end
end

get '/users/login' do
  erb :'users/login'
end

post '/users/login' do
  user = User.find_by(username: params[:username])
  redirect '/users/login' unless user
  if user && check_password(user, params[:password])
    session[:session_token] = SecureRandom.urlsafe_base64()
    user.update!(session_token: session[:session_token])
    redirect '/logged_in'
  else
    redirect '/users/login'
  end
end

get '/logged_in' do
  erb :"/loggedin"
end


get '/users/profile' do
  erb :'users/profile'
end
