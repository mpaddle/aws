{-# LANGUAGE RecordWildCards, MultiParamTypeClasses, FlexibleInstances #-}

module Aws.SimpleDb.ListDomains
where

import Aws.Query
import Aws.SimpleDb.Error
import Aws.SimpleDb.Info
import Aws.SimpleDb.Response
import Aws.Transaction
import Control.Applicative
import MonadLib.Compose
import Text.XML.Monad

data ListDomains
    = ListDomains {
        ldMaxNumberOfDomains :: Maybe Int
      , ldNextToken :: Maybe String
      }
    deriving (Show)

data ListDomainsResponse 
    = ListDomainsResponse {
        ldrDomainNames :: [String]
      , ldrNextToken :: Maybe String
      }
    deriving (Show)

listDomains :: ListDomains
listDomains = ListDomains { ldMaxNumberOfDomains = Nothing, ldNextToken = Nothing }
             
instance AsQuery ListDomains SdbInfo where
    asQuery i ListDomains{..} = addQuery [("Action", "ListDomains")]
                                . addQueryMaybe show ("MaxNumberOfDomains", ldMaxNumberOfDomains)
                                . addQueryMaybe id ("NextToken", ldNextToken)
                                $ sdbiBaseQuery i

instance SdbFromResponse ListDomainsResponse where
    sdbFromResponse = do
      testElementNameUI "ListDomainsResponse"
      names <- inList strContent <<< findElementsNameUI "DomainName"
      nextToken <- tryMaybe $ strContent <<< findElementNameUI "NextToken"
      return $ ListDomainsResponse names nextToken

instance Transaction ListDomains SdbInfo (SdbResponse ListDomainsResponse) SdbError