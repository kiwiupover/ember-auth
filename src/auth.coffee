window.Auth = Em.Object.create
  # =====================
  # Public API
  # =====================

  # Holds auth token
  authToken: null

  # Holds current user ID
  currentUserId: null

  # Holds error from token API requests
  error: null

  # Holds prev route for smart redirect.
  prevRoute: null

  # Sign in method
  #
  # This will make an API call to retrieve auth token.
  #
  # On success:
  #   It will store auth token in @authToken
  #   and its associated user model ID in @currentUserId.
  # On error:
  #   It will store the response body, unaltered, in @error.
  #
  # @param {data} object params to pass to API end point in ajax call
  signIn: (data = {}) ->
    @ajax Auth.Config.get('tokenCreateUrl'), 'POST',
      data: data
      success: (json) =>
        @set 'authToken', json[Auth.Config.get('tokenKey')]
        @set 'currentUserId', json[Auth.Config.get('idKey')]
      error: (json) =>
        @set 'error', json

  # Sign out method
  #
  # This will make an API call to destroy auth token.
  # It will pass the auth token along as a param,
  # using the key set at @tokenKey.
  #
  # On success:
  #   It will set @authToken and @currentUserId to null.
  # On error:
  #   It will store the response body, unaltered, in @error.
  #
  # @param {data} object params to pass to API end point in ajax call
  signOut: (data = {}) ->
    data[Auth.Config.get('tokenKey')] = @get('authToken')
    @ajax Auth.Config.get('tokenDestroyUrl'), 'DELETE',
      data: data
      success: (json) =>
        @set 'authToken', null
        @set 'currentUserId', null
      error: (json) =>
        @set 'error', json

  # =====================
  # End of Public API
  # =====================

  # Resovles sign in redirect destination
  resolveSignInRedirectRoute: ->
    @resolveRedirectRoute 'signIn'

  # Resovles sign out redirect destination
  resolveSignOutRedirectRoute: ->
    @resolveRedirectRoute 'signOut'

  # Resolves redirect destination
  # @param {type} string 'signIn' or 'signOut'
  resolveRedirectRoute: (type) ->
    return null unless type in ['signIn', 'signOut']

    typeClassCase = "#{type[0].toUpperCase()}#{type.slice(1)}"
    isSmart  = Auth.Config.get "smart#{typeClassCase}Redirect"
    fallback = Auth.Config.get "#{type}RedirectRoute"

    return fallback unless isSmart

    if @prevRoute != Auth.Config.get('signInRoute')
      @prevRoute
    else
      fallback

  ajax: (url, type, hash) ->
    hash.url         = url
    hash.type        = type
    hash.dataType    = 'json'
    hash.contentType = 'application/json; charset=utf-8'

    if hash.data && type != 'GET'
      hash.data = JSON.stringify(hash.data)

    jQuery.ajax(hash)
