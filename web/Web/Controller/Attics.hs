module Web.Controller.Attics where

import Application.Helper.Queries
import Web.Controller.Prelude
import Web.View.Attics.Bands
import Web.View.Attics.Performances
import Web.View.Attics.Recordings
import Web.View.Attics.Player
import qualified Data.Text as Text
import Web.View.Prelude (HomeView (..))
import Web.View.Layout
import qualified Data.HashMap.Strict as HashMap
import qualified IHP.Log as Log
import qualified Data.List as List

renderHome :: _ => IO ()
renderHome = do
    bands <- query @Band |> fetchCount
    shows <- query @Performance |> fetchCount
    render HomeView { .. }

isJsonRequest :: _ => Bool
isJsonRequest = getHeader "Accept" == "application/json"

instance Controller AtticsController where
    action HomeAction = do
        setLayout homeLayout
        renderHome

    action BandsAction = do
        bands <- fetchBands
        render BandsView {..}

    action TopPerformancesAction {collection} = do
        let n = paramOrDefault 5 "numPerformances"
        band <- fetchBandByCollection collection
        topPerformances <- sortBy (\a b -> fst a `compare` fst b) . HashMap.toList <$> fetchTopPerformances collection n
        render TopPerformancesView {..}

    action ShowBandAction {collection, year} = do
        band <- fetchBandByCollection collection
        performances <- fetchPerformances collection year
        render PerformancesView { .. }

    action RecordingsAction {collection, date} = do
        unless isJsonRequest (redirectTo (PlayerAction collection date Nothing Nothing))
        band <- fetchBandByCollection collection
        performance <- fetchPerformance collection date
        recordings <- fetchRecordings collection date
        render RecordingsView { .. }

    action ShowRecordingAction {identifier} = if isJsonRequest
        then do
        recording <- query @Recording |> filterWhere (#identifier, identifier) |> fetchOne
        performanceWithMetadata <- fetchPerformanceWithMetadataFromId (get #performanceId recording)
        band <- performanceWithMetadata |> get #performance |> get #bandId |> fetch
        songs <- query @Song |> filterWhere (#recordingId, get #id recording) |> fetch
        render ShowRecordingView { .. }
        else renderHome

<<<<<<< HEAD
    action (MigrationAction _) =
        if isJsonRequest then
=======
    action (MigrationAction _) = 
        if isJsonRequest then 
>>>>>>> upstream/master
            do
                let idStr :: Text = param "identifiers"
                let identifiers = Text.splitOn "," (cs idStr)
                items <- fetchMigrationItems identifiers
                render MigrationView { .. }
<<<<<<< HEAD
        else
=======
        else 
>>>>>>> upstream/master
            renderHome

    action playerAction@PlayerAction { .. } = do
        band <- fetchBandByCollection collection
        performance <- query @Performance
            |> filterWhere (#bandId, get #id band)
            |> filterWhere (#date, date)
            |> fetchOne
        recordings <- fetchRecordings collection date
        let selectedRecording = fromMaybe (recordings !! 0) $ do
                id <- selectedIdentifier
                let list = filter (\r -> get #identifier r == id) recordings
                head list
        songs <- query @Song |> filterWhere (#recordingId, get #id selectedRecording) |> orderByAsc #track |> fetch

        -- NOTE: track is indexed by 1!!!!
        playerState <- case selectedTrack of
                Just track -> do
                    when (track > List.length songs) (redirectTo playerAction { selectedTrack = Nothing })
                    let songTitle = get #title (songs !! (track - 1))
                    let state = Just $ PlayerState
                            songTitle
                            (tshow track)
                            (get #date performance)
                            (get #name band)
                            (get #collection band)
                            (get #venue performance)
                    putContext (PageTitle songTitle)
                    pure state
                Nothing -> pure Nothing

        case playerState of
            Just playerState -> playerState |> get #songTitle |> PageTitle |> putContext
            Nothing -> pure ()

        render PlayerView {
            band=band,
            performance=performance,
            selectedRecording=selectedRecording,
            recordings=recordings,
            songs=songs,
            playerState=playerState
        }

