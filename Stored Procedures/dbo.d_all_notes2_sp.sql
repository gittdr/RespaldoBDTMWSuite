SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_all_notes2_sp] (@lgh int)
AS

DECLARE @showexpired CHAR(1)
		, @grace INTEGER

SELECT @showexpired =isnull(gi_string1,'Y')
FROM generalinfo
WHERE gi_name = 'showexpirednotes'

SELECT @grace =isnull(gi_integer1,0)
FROM generalinfo
WHERE gi_name = 'showexpirednotesgrace'

DECLARE @ord TABLE (
	ord_hdrnumber VARCHAR(12)
	 )

INSERT INTO @ord
SELECT DISTINCT CAST(ord_hdrnumber AS VARCHAR(12))
FROM stops
WHERE mov_number IN (SELECT mov_number FROM stops WHERE lgh_number = @lgh)
  AND ord_hdrnumber > 0

select notes.not_type, not_urgent, not_text, not_expires, ntb_table, nre_tablekey, not_sequence, not_number, last_updatedby, last_updatedatetime, not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from
from notes, @ord
WHERE	(notes.ntb_table = 'orderheader' AND notes.nre_tablekey = ord_hdrnumber)
  AND	IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
			end

UNION

SELECT not_type, not_urgent, not_text, not_expires, ntb_table, nre_tablekey, not_sequence, not_number, last_updatedby, last_updatedatetime, not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from
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

SELECT DISTINCT not_type, not_urgent, not_text, not_expires, ntb_table, nre_tablekey, not_sequence, not_number, last_updatedby, last_updatedatetime, not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from
FROM stops INNER JOIN orderheader oh on stops.mov_number = oh.mov_number
	INNER JOIN notes ON (notes.ntb_table = 'company' AND ((notes.nre_tablekey = ord_billto 
			OR notes.nre_tablekey = ord_supplier 
			OR notes.nre_tablekey = ord_customer 
			OR notes.nre_tablekey = ord_shipper 
			OR notes.nre_tablekey = ord_consignee))) 
WHERE 	stops.lgh_number = @lgh
		AND IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
			end
--broke these apart below to improve performance
--PTS52867
UNION
SELECT not_type, not_urgent, not_text, not_expires, ntb_table, nre_tablekey, not_sequence, not_number, last_updatedby, last_updatedatetime, not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from
FROM notes inner join legheader on nre_tablekey = lgh_driver1
WHERE lgh_number = @lgh
AND (ntb_table = 'manpowerprofile')
AND IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
end

UNION
SELECT not_type, not_urgent, not_text, not_expires, ntb_table, nre_tablekey, not_sequence, not_number, last_updatedby, last_updatedatetime, not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from
FROM notes inner join legheader on nre_tablekey = lgh_driver2
WHERE lgh_number = @lgh
	and (ntb_table = 'manpowerprofile')
AND IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate())
end 

UNION
SELECT not_type, not_urgent, not_text, not_expires, ntb_table, nre_tablekey, not_sequence, not_number, last_updatedby, last_updatedatetime, not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from
FROM notes inner join legheader on nre_tablekey = lgh_tractor
WHERE lgh_number = @lgh

	and (ntb_table = 'tractorprofile')
AND IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
end

UNION
SELECT not_type, not_urgent, not_text, not_expires, ntb_table, nre_tablekey, not_sequence, not_number, last_updatedby, last_updatedatetime, not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from
FROM notes inner join legheader on nre_tablekey = lgh_primary_trailer
WHERE lgh_number = @lgh

	and (ntb_table = 'trailerprofile')
AND IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
end
UNION
SELECT not_type, not_urgent, not_text, not_expires, ntb_table, nre_tablekey, not_sequence, not_number, last_updatedby, last_updatedatetime, not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from
FROM notes inner join legheader on nre_tablekey = lgh_primary_pup
WHERE lgh_number = @lgh

	and (ntb_table = 'trailerprofile')
AND IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
end
UNION
SELECT not_type, not_urgent, not_text, not_expires, ntb_table, nre_tablekey, not_sequence, not_number, last_updatedby, last_updatedatetime, not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from
FROM notes inner join legheader on nre_tablekey = lgh_carrier
WHERE lgh_number = @lgh
	and (ntb_table = 'carrier' )
AND IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate())
end 
UNION
SELECT not_type, not_urgent, not_text, not_expires, ntb_table, nre_tablekey, not_sequence, not_number, last_updatedby, last_updatedatetime, not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from
FROM notes inner join legheader on nre_tablekey = CAST(mov_number AS VARCHAR(12))

WHERE lgh_number = @lgh
	and ntb_table = 'movement'  
AND IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
			end 

GO
GRANT EXECUTE ON  [dbo].[d_all_notes2_sp] TO [public]
GO
