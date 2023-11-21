class Base < Grape::API
	helpers ResponseBase
	mount ApiV1
end