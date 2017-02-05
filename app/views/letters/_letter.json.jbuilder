json.extract! letter, :id, :title, :body, :created_at, :updated_at
json.url letter_url(letter, format: :json)