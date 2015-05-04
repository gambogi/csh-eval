{-|
Module      : CSH.LDAP
Description : LDAP convenience function and examples
Copyright   : Stephen Demos, Matt Gambogi, Travis Whitaker, Computer Science House 2015
License     : MIT
Maintainer  : pvals@csh.rit.edu
Stability   : Provisional
Portability : POSIX

CSH.LDAP provides methods useful for interacting with CSH's LDAP configuration
-}

{-# LANGUAGE Trustworthy, OverloadedStrings #-}
module CSH.LDAP
( userBaseTxt
, appBaseTxt
, groupBaseTxt
, committeeBaseTxt
, appDn
, userDn
, withCSH
) where

import Ldap.Client
import Safe
import Data.Text as T

-- | Generates a base given an Org Unit (ou) name.
cshBaseTxt :: T.Text -- ^ ou name
           -> T.Text
cshBaseTxt str = T.concat ["ou=", str, ",dc=csh,dc=rit,dc=edu"]

-- | Distinct name for users
userBaseTxt :: T.Text
userBaseTxt = cshBaseTxt "users"

-- | Distinct name for apps
appBaseTxt :: T.Text
appBaseTxt = cshBaseTxt "apps"

-- | Distinct name for groups
groupBaseTxt :: T.Text
groupBaseTxt = cshBaseTxt "groups"

-- | Distinct name for committees
committeeBaseTxt :: T.Text
committeeBaseTxt = cshBaseTxt "committees"

-- | Creates a Dn based on the name of the application
appDn :: Text -- ^ Common name of app
      -> Dn
appDn app = Dn $ T.concat ["cn=", app, ",", appBaseTxt]

-- | Creates a Dn based on the uid of the user
userDn :: Text -- ^ uid of user
       -> Dn
userDn user = Dn $ T.concat ["uid=", user, ",", userBaseTxt]

{- | Wraps LDAP transactions.
For example, here is a function that will retrieve a user from LDAP, given
a username/password pair and a user to search for:

@
     import CSH.LDAP
     import Ldap.Client

     fetchUser usr pass searchuser  = withCSH $ \l -> do
                     bind  l (userDn usr) (Password pass)
                     user <- search l (Dn userBaseTxt)
                                       (typesOnly False)
                                       (Attr "uid" := searchuser)
                                       []
                     return user
@
-}
withCSH :: (Ldap -> IO a) -> IO (Either LdapError a)
withCSH = with (Secure "ldap.csh.rit.edu") 636

