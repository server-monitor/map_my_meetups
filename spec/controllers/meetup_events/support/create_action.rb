
def post_create(input_text = '')
  process(
    :create,
    method: :post,
    params: { input_text: input_text },
    format: :js
  )
end
