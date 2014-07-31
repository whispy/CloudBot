import random

from util import hook, http

api_key = "dc6zaTOxFJmzC"
@hook.command('gif')
@hook.command
def giphy(inp):
    '''.gif/.giphy <query> -- returns first giphy search result'''
    url = 'http://api.giphy.com/v1/gifs/search'
    try:
        response = http.get_json(url, q=inp, limit=10, api_key=api_key)
    except http.HTTPError as e:
        return e.msg

    results = response.get('data')
    if results:
        return random.choice(results).get('bitly_gif_url')
    else:
        return 'no results found'