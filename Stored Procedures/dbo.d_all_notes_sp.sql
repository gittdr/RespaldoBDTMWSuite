SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_all_notes_sp] (@lgh int)
AS

DECLARE @showexpired CHAR(1)
		, @grace INTEGER

SELECT @showexpired =isnull(gi_string1,'Y')
FROM generalinfo
WHERE gi_name = 'showexpirednotes'

SELECT @grace =isnull(gi_integer1,0)
FROM generalinfo
WHERE gi_name = 'showexpirednotesgrace'

DECLARE @ord TABLE (ord_hdrnumber VARCHAR(12))
INSERT INTO @ord
SELECT DISTINCT CAST(ord_hdrnumber AS VARCHAR(12))
FROM stops
WHERE mov_number IN (SELECT mov_number FROM stops WHERE lgh_number = @lgh)
  AND ord_hdrnumber > 0

select notes.not_type, not_urgent, not_text, not_expires, ntb_table, nre_tablekey, not_sequence
from notes, @ord
WHERE	(notes.ntb_table = 'orderheader' AND notes.nre_tablekey = ord_hdrnumber)
  AND	IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
			end

UNION

SELECT not_type, not_urgent, not_text, not_expires, ntb_table, nre_tablekey, not_sequence
FROM notes, stops
WHERE lgh_number = @lgh
AND notes.ntb_table = 'company' 
AND notes.nre_tablekey = cmp_id
  AND	IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
			end

UNION

SELECT not_type, not_urgent, not_text, not_expires, ntb_table, nre_tablekey, not_sequence
FROM notes, legheader
WHERE lgh_number = @lgh
AND ((ntb_table = 'manpowerprofile' AND nre_tablekey = lgh_driver1)
	OR (ntb_table = 'manpowerprofile' AND nre_tablekey = lgh_driver2)
	OR (ntb_table = 'tractorprofile' AND nre_tablekey = lgh_tractor)
	OR (ntb_table = 'trailerprofile' AND nre_tablekey = lgh_primary_trailer)
	OR (ntb_table = 'trailerprofile' AND nre_tablekey = lgh_primary_pup))
AND IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
			end

GO
GRANT EXECUTE ON  [dbo].[d_all_notes_sp] TO [public]
GO
