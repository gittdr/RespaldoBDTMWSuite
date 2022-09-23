SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**
 * 
 * NAME:
 * dbo.Ops_TM_MoveNotesToSend
 *
 * DESCRIPTION:
 * Pull notes for @lgh_number
 *
 * PARAMETERS:
 * 001 - @lgh_number int
 * 
 * REVISION HISTORY:
 * 11/28/2017 - NSUITE202159 - MIZ - Wrote proc based on tm_movenotestosend which is the one used by core TMWSuite.
 *
 **/

CREATE PROC [dbo].[Ops_TM_MoveNotesToSend] @lgh_number int=0

AS

DECLARE @mov_number int,
		@use_large_notes char(1)

DECLARE @noteList TABLE (not_number integer, 
						 not_subject varchar(254))
DECLARE @keyList TABLE (ntb_table char(18), 
						nre_tablekey char(18), 
						not_subject varchar(18)) 
DECLARE @unique_list TABLE (not_number integer,
							not_subject varchar(254)) 

SET NOCOUNT ON

SELECT @mov_number = mov_number 
FROM legheader WHERE lgh_number = @lgh_number

SELECT @use_large_notes = gi_string1 
FROM generalinfo 
WHERE gi_name = 'UseLargeNotes'

IF @use_large_notes IS NULL
	SET @use_large_notes = 'N'
	
-- Get our mov_number
INSERT @keyList(ntb_table, nre_tablekey, not_subject)
SELECT 'movement', @mov_number, 'MOV: ' + CONVERT(varchar(13), @mov_number)
WHERE ISNULL(@mov_number, 0) <> 0

-- Order notes
INSERT @keyList(ntb_table, nre_tablekey, not_subject)
SELECT DISTINCT 'orderheader', orderheader.ord_hdrnumber, 'ORD: ' + CONVERT(varchar(13), orderheader.ord_number)
FROM stops 
INNER JOIN orderheader ON stops.ord_hdrnumber = orderheader.ord_hdrnumber 
WHERE stops.mov_number = @mov_number 
	AND ISNULL(stops.ord_hdrnumber, 0) <> 0

-- Get the Bill To
INSERT @keyList(ntb_table, nre_tablekey, not_subject)
SELECT DISTINCT 'company', orderheader.ord_billto, 'COMP: ' + orderheader.ord_billto
FROM stops 
INNER JOIN orderheader ON stops.ord_hdrnumber = orderheader.ord_hdrnumber 
WHERE stops.mov_number = @mov_number 
	AND ISNULL( orderheader.ord_billto, 'UNKNOWN')<>'UNKNOWN'

-- Get all companies on this leg
INSERT @keyList(ntb_table, nre_tablekey, not_subject)
SELECT DISTINCT 'company', cmp_id, 'COMP: ' + cmp_id
FROM stops 
WHERE lgh_number = @lgh_number 
	AND ISNULL(cmp_id, 'UNKNOWN')<>'UNKNOWN'

-- Get all Driver1's on this leg
INSERT @keyList(ntb_table, nre_tablekey, not_subject)
SELECT DISTINCT 'manpowerprofile', event.evt_driver1, 'DRV: ' + event.evt_driver1
FROM stops 
INNER JOIN event ON stops.stp_number = event.stp_number 
WHERE stops.lgh_number = @lgh_number 
	AND ISNULL(event.evt_driver1, 'UNKNOWN')<>'UNKNOWN'

-- Get all Driver2's on this leg
INSERT @keyList(ntb_table, nre_tablekey, not_subject)
SELECT DISTINCT 'manpowerprofile', event.evt_driver2, 'DRV: ' + event.evt_driver2
FROM stops 
INNER JOIN event ON stops.stp_number = event.stp_number 
WHERE stops.lgh_number = @lgh_number 
	AND ISNULL(event.evt_driver2, 'UNKNOWN')<>'UNKNOWN'

-- Get all tractors on this leg
INSERT @keyList(ntb_table, nre_tablekey, not_subject)
SELECT DISTINCT 'tractorprofile', event.evt_tractor, 'TRC: ' + event.evt_tractor
FROM stops 
INNER JOIN event ON stops.stp_number = event.stp_number 
WHERE stops.lgh_number = @lgh_number 
	AND ISNULL(event.evt_tractor, 'UNKNOWN')<>'UNKNOWN'

-- Get all trailer1's on this leg
INSERT @keyList(ntb_table, nre_tablekey, not_subject)
SELECT DISTINCT 'trailerprofile', event.evt_trailer1, 'TRL: ' + event.evt_trailer1
FROM stops 
INNER JOIN event ON stops.stp_number = event.stp_number 
WHERE stops.lgh_number = @lgh_number 
	AND ISNULL(event.evt_trailer1, 'UNKNOWN')<>'UNKNOWN'

-- Get all the trailer2's on this leg
INSERT @keyList(ntb_table, nre_tablekey, not_subject)
SELECT DISTINCT 'trailerprofile', event.evt_trailer2, 'TRL: ' + event.evt_trailer2
FROM stops 
INNER JOIN event ON stops.stp_number = event.stp_number 
WHERE stops.lgh_number = @lgh_number 
	AND ISNULL(event.evt_trailer2, 'UNKNOWN')<>'UNKNOWN'

INSERT @keyList(ntb_table, nre_tablekey, not_subject)
SELECT DISTINCT 'invoiceheader', invoiceheader.ivh_hdrnumber, 'INV: ' + invoiceheader.ivh_invoicenumber
FROM stops 
INNER JOIN invoiceheader ON stops.ord_hdrnumber = invoiceheader.ord_hdrnumber 
WHERE stops.mov_number = @mov_number 
	AND ISNULL(invoiceheader.ivh_hdrnumber, 0)<>0

-- Get all commodities on this leg
INSERT @keyList(ntb_table, nre_tablekey, not_subject)
SELECT DISTINCT 'commodity', freightdetail.cmd_code, 'CMD: ' + freightdetail.cmd_code
FROM freightdetail 
INNER JOIN stops ON stops.stp_number = freightdetail.stp_number 
WHERE stops.lgh_number = @lgh_number 
	AND isnull(freightdetail.cmd_code, 'UNKNOWN')<>'UNKNOWN'

-- Get all carrier's on this leg
INSERT @keyList(ntb_table, nre_tablekey, not_subject)
SELECT DISTINCT 'carrier', event.evt_carrier, 'CAR: ' + event.evt_carrier
FROM stops 
INNER JOIN event ON stops.stp_number = event.stp_number 
WHERE stops.lgh_number = @lgh_number 
	AND ISNULL(event.evt_carrier, 'UNKNOWN')<>'UNKNOWN'

-- Pull all notes for the keys we've gathered.
INSERT INTO @noteList (not_number, not_subject)
SELECT notes.not_number, kl.not_subject
FROM @keyList kl
INNER JOIN notes ON kl.ntb_table = notes.ntb_table AND kl.nre_tablekey = notes.nre_tablekey
WHERE notes.not_tmsend = 1

-- Eliminate any duplicates
INSERT INTO @unique_list (not_number)	
SELECT DISTINCT not_number
FROM @noteList

-- Get the subject
UPDATE ul
SET not_subject = nl.not_subject
FROM @unique_list ul
INNER JOIN @noteList nl ON ul.not_number = nl.not_number

IF @use_large_notes = 'Y' 
	SELECT ul.not_number, LEFT(RTRIM(ul.not_subject) + SPACE(1) + notes.not_text, 254), CAST (not_text_large AS varchar (8000)) AS not_text_large
	FROM @unique_list ul 
	INNER JOIN notes ON ul.not_number = notes.not_number
	WHERE DATALENGTH(not_text_large) > 0
		AND not_expires > GETDATE()
	ORDER BY notes.ntb_table, notes.nre_tablekey
ELSE
	SELECT ul.not_number, LEFT(RTRIM(ul.not_subject) + SPACE(1) + notes.not_text, 254), notes.not_text
	FROM @unique_list ul 
	INNER JOIN notes ON ul.not_number = notes.not_number
	WHERE ISNULL(notes.not_text, '') <> ''
		AND not_expires > GETDATE()
	ORDER BY notes.ntb_table, notes.nre_tablekey
GO
GRANT EXECUTE ON  [dbo].[Ops_TM_MoveNotesToSend] TO [public]
GO
