import datetime
from django.contrib.auth import logout


class NoCacheMiddleware(object):

    def process_response(self, request, response):
        if response and type( response ) != type:
            #if hasattr(request, 'session'): request.session.set_expiry(1500) 
            response['Pragma'] = 'no-cache'
            response['Cache-Control'] = 'no-cache must-revalidate proxy-revalidate no-store'
        return response
    

class timeOutMiddleware(object):

    def process_request(self, request):
        if request.user.is_authenticated():
            if 'lastRequest' in request.session:            
                elapsedTime = datetime.datetime.now() - request.session['lastRequest']
                if elapsedTime.seconds > 15*60:
                    del request.session['lastRequest'] 
                    logout(request)

            request.session['lastRequest'] = datetime.datetime.now()
        else:
            if 'lastRequest' in request.session:
                del request.session['lastRequest'] 

        return None

class IncludeLoginInErrors(object):  
    #http://stackoverflow.com/questions/9294043/include-django-logged-user-in-django-traceback-error
    def process_exception(self, request, exception):
        """
        Process the request to add some variables to it.
        """

        # Add other details about the user to the META CGI variables.
        try:
            if request.user.is_anonymous():
                request.META['AUTH_NAME'] = "Anonymous User"
                request.META['AUTH_USER'] = "Anonymous User"
                request.META['AUTH_USER_EMAIL'] = ""
                request.META['AUTH_USER_ID'] = 0
                request.META['AUTH_USER_IS_ACTIVE'] = False
                request.META['AUTH_USER_IS_SUPERUSER'] = False
                request.META['AUTH_USER_IS_STAFF'] = False
                request.META['AUTH_USER_LAST_LOGIN'] = ""
            else:
                request.META['AUTH_NAME'] = str(request.user.first_name) + " " + str(request.user.last_name)
                request.META['AUTH_USER'] = str(request.user.username)
                request.META['AUTH_USER_EMAIL'] = str(request.user.email)
                request.META['AUTH_USER_ID'] = str(request.user.id)
                request.META['AUTH_USER_IS_ACTIVE'] = str(request.user.is_active)
                request.META['AUTH_USER_IS_SUPERUSER'] = str(request.user.is_superuser)
                request.META['AUTH_USER_IS_STAFF'] = str(request.user.is_staff)
                request.META['AUTH_USER_LAST_LOGIN'] = str(request.user.last_login)
        except:
            pass
    
    