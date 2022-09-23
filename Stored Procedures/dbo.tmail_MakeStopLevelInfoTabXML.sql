SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tmail_MakeStopLevelInfoTabXML] 
		@OrderNumber					AS VARCHAR(12),
		@StopCompanyID					AS VARCHAR(8)							 

AS

-- =================================================================================================
-- Stored Proc: tmail_MakeStopLevelInfoTabXML
-- Author     :	Sensabaugh, Virgil
-- Create date: 2014.11.10
-- Description: Collects data from the Notes and ReferenceNumber tables which is attached to the 
--              WF Trip Plan stop. Any records found will be placed in the WF XML at the TripPlan
--				stop level.
--      
--      Outputs:
--      --------------------------------------------------------------------------------------------
--      @XMLForStopLevelInfoTab	VARCHAR(MAX)
--
--      Input parameters:
--      --------------------------------------------------------------------------------------------
--		@OrderNumber			VARCHAR(12)
--		@CompanyID  			VARCHAR(8)
--
-- =================================================================================================
-- Modification Log:
-- PTS 83368 - VMS - 2014.11.10 - Created
--
-- =================================================================================================
-- Testing:
-- EXEC tmail_MakeStopLevelInfoTabXML '626', 'CWRCLE'
-- =================================================================================================

	BEGIN

		CREATE TABLE #StopNotes (
						sn				 int identity, 
						Notes			 varchar(255), 
						NotesNoWrap		 varchar(max),
						AttachedTo		 varchar(20), 
						Regarding		 varchar(50),
						RegardingAbbr	 varchar(20),
						AttachedToKey	 varchar(20), 
						NoteNum			 int
						)

		DECLARE @BegXML					AS VARCHAR(150)
		DECLARE @EndXML					AS VARCHAR(10)
		DECLARE @PrefixXML				AS VARCHAR(300)

		DECLARE @StopNotesXML			AS VARCHAR(MAX)
		DECLARE @XMLForStopNotes		AS VARCHAR(MAX)

		DECLARE @StopRefInfoXML			AS VARCHAR(MAX)
		DECLARE @XMLForStopRefInfo		AS VARCHAR(MAX)

		DECLARE @StopLevelInfoXML		AS VARCHAR(MAX)

		-- -----------------------------------------------------------------------------------------
		SET @BegXML = '<data id ="InfoPlusForStopRefsAndNotes"><datum name="type" value="info"/>'
		SET @EndXML = '</data>'

		-- -----------------------------------------------------------------------------------------
		-- Make the Notes section of the Stop Info Tab.
		-- -----------------------------------------------------------------------------------------
		-- Use the existing stored proc tmail_get_notes2_sp to retrieve notes attached to the 
		-- order/TripPlan.
		-- NOTE: Each company location (stop) has a unique Company ID so the correct note will be
		--       pulled for the stop.
		-- -----------------------------------------------------------------------------------------
		INSERT INTO #StopNotes (
						Notes , 
						NotesNoWrap ,
						AttachedTo , 
						Regarding,
						RegardingAbbr,
						AttachedToKey , 
						NoteNum )
			EXEC tmail_get_notes4_sp 'company',@StopCompanyID,'','4000'
		-- -----------------------------------------------------------------------------------------
		-- Place any notes found into the output XML format.
		-- -----------------------------------------------------------------------------------------
		SELECT @StopNotesXML = (
			SELECT	
					'StopNotes' + CONVERT(VARCHAR(9), #StopNotes.NoteNum) AS '@id',
					'type' AS 'datum/@name',
					'customItem' AS 'datum/@value',
					'',
					'sortId' AS 'datum/@name',
					sn AS 'datum/@value',
					'',
					'customLabel' AS 'datum/@name', 
					'Note ' + CONVERT(VARCHAR(9),ROW_NUMBER() OVER( ORDER BY #StopNotes.NoteNum)) AS 'datum/@value', 
					'',
					'customValue' AS 'datum/@name', 
					Notes AS 'datum/@value' 
			  FROM  #StopNotes
			   FOR  XML PATH('data')
			)

		SET @PrefixXML =   
   				'<data id="StopInfoTabNotesHdr">' + 
   				'<datum name="type" value="customItem" />' +
				'<datum name="sortId" value="300" />' +
				'<datum name="customLabel" value=" [ Notes ] " />' +
				'<datum name="customValue" value=" " />' +
				'</data>'
		   
		SET @XMLForStopNotes = @PrefixXML + ISNULL(@StopNotesXML,'')

		DROP TABLE #StopNotes 

		-- -----------------------------------------------------------------------------------------
		-- Make the Reference Number section of the Stop Info Tab.
		-- -----------------------------------------------------------------------------------------
		SELECT  @StopRefInfoXML = (
			SELECT 
					'StopRefInfo' + convert(VARCHAR(9),STP.stp_number ) AS '@id',
					'type' AS 'datum/@name',
					'customItem' AS 'datum/@value',
					'',
					'sortId' AS 'datum/@name',
					100 + ROW_NUMBER() OVER( ORDER BY REF.ref_sequence) AS 'datum/@value',
					'',
					'customLabel' AS 'datum/@name', 
					LBL.name AS 'datum/@value', 
					'',
					'customValue' AS 'datum/@name', 
					REF.ref_number AS 'datum/@value' 
			  FROM dbo.referencenumber AS REF
			  JOIN dbo.stops AS STP 
				ON REF.ref_tablekey = STP.stp_number 
			  JOIN dbo.labelfile AS LBL
			    ON REF.ref_type = LBL.abbr 
			 WHERE REF.ref_table = 'stops'
			   AND STP.cmp_id = @StopCompanyID and STP.ord_hdrnumber = @OrderNumber
				   ORDER BY REF.ref_sequence
			   FOR XML PATH('data')
			   )
		   
		SET @PrefixXML =   
   				'<data id="StopInfoTabRefInfoHdr">' + 
   				'<datum name="type" value="customItem" />' +
				'<datum name="sortId" value="100" />' +
				'<datum name="customLabel" value=" [ Reference Information ] " />' +
				'<datum name="customValue" value=" " />' +
				'</data>'
		   
		SET @XMLForStopRefInfo = @PrefixXML + ISNULL(@StopRefInfoXML,'')
		-- =========================================================================================
		SET @StopLevelInfoXML = @BegXML + @XMLForStopRefInfo + @XMLForStopNotes + @EndXML

		SELECT @StopLevelInfoXML 'StopLevelInfoXML'

	END

GO
GRANT EXECUTE ON  [dbo].[tmail_MakeStopLevelInfoTabXML] TO [public]
GO
