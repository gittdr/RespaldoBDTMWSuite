SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_notes_sp] (@table char(18), @key char(18))
AS

/* PTS 32575 - DJM - Removed the timestamp column to avoid MS SQL 2005 problems.	*/
/* PTS35974 -JG - fix performance in "Convert (char (12), TASK.TASK_LINK_ENTITY_SYS_VALUE) =@key" */

declare @ord_number varchar(12)
declare @showexpired char(1)
declare @grace integer
declare @uselargenotes char(1)

select @showexpired =isnull(gi_string1,'Y')
from generalinfo
where gi_name = 'showexpirednotes'

select @grace =isnull(gi_integer1,0)
from generalinfo
where gi_name = 'showexpirednotesgrace'

--JLB PTS 20098  Ability to have a text field on the notes windows.
select @uselargenotes = isnull(gi_string1,'N')
from generalinfo
where gi_name = 'uselargenotes'

--Commented out for PTS 24849 CGK 10/6/2004
--SELECT	notes.not_number,   
--        notes.not_text,   
--       notes.not_type,   
--       notes.not_urgent,   
--        notes.not_senton,   
--        notes.not_sentby,   
--        notes.not_expires,   
--        notes.not_forwardedfrom,   
--        notes.timestamp,   
--        notes.ntb_table,   
--        notes.nre_tablekey,   
--        notes.not_sequence,   
--        notes.last_updatedby,   
--        notes.last_updatedatetime, 
--		'            ' ord_number,
--		autonote,
--		--vmj2+	PTS 16582	01/08/2003	This column is used by w_notes_simple to control
--		--which rows may be edited..
--		'N' as protect_row,
--	--PTS 20098
--	--PTS 20814  update to logic of 20098 to allow totalmail and loadtender updates to large notes without changing their code
--	CASE WHEN ISNULL(notes.not_text,'') = ISNULL(SUBSTRING(notes.not_text_large,1,254),'') THEN notes.not_text_large ELSE CONVERT(text, notes.not_text) END not_text,
--	--notes.not_text_large,
--	--end 20814
--	@uselargenotes AS use_large,
--	isnull(not_viewlevel,''),
--	--end PTS 20098
--		--vmj2-
--        notes.ntb_table_copied_from, /*PTS 22790 CGK 8/30/04*/
--	notes.nre_tablekey_copied_from, /*PTS 22790 CGK 8/30/04*/
--	notes.not_number_copied_from /*PTS 22790 CGK 8/30/04*/
--  FROM 	notes  
--  WHERE	(notes.ntb_table = @table AND notes.nre_tablekey = @key)
--	and	IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
--			case @showexpired 
--				when 'N' then getdate()
--				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
--			end

--Her to bottom Added for PTS 24849 CGK 10/6/2004
CREATE TABLE #notes (
	not_number int NOT NULL ,
	not_text varchar (254) NULL ,
	not_type varchar (6)  NULL ,
	not_urgent char (1)  NULL ,
	not_senton datetime NULL ,
	not_sentby varchar (6)  NULL ,
	not_expires datetime NULL ,
	not_forwardedfrom int NULL ,
	ntb_table char (18)  NULL ,
	nre_tablekey char (18)  NULL ,
	not_sequence smallint NULL ,
	last_updatedby char (20)  NULL ,
	last_updatedatetime datetime NULL ,
	autonote char (1)  NULL ,
	not_text_large text  NULL ,
	not_viewlevel varchar (6)  NULL ,
	ntb_table_copied_from varchar (18)  NULL ,
	nre_tablekey_copied_from varchar (18)  NULL ,
	not_number_copied_from int NULL 
) 

Insert into #Notes (not_number ,
	not_text ,
	not_type ,
	not_urgent,
	not_senton ,
	not_sentby,
	not_expires ,
	not_forwardedfrom ,
	ntb_table ,
	nre_tablekey ,
	not_sequence ,
	last_updatedby,
	last_updatedatetime ,
	autonote ,
	not_text_large ,
	not_viewlevel ,
	ntb_table_copied_from ,
	nre_tablekey_copied_from ,
	not_number_copied_from)
SELECT not_number ,
	not_text ,
	not_type ,
	not_urgent,
	not_senton ,
	not_sentby,
	not_expires ,
	not_forwardedfrom ,
	ntb_table ,
	nre_tablekey ,
	not_sequence ,
	last_updatedby,
	last_updatedatetime ,
	autonote ,
	not_text_large ,
	not_viewlevel ,
	ntb_table_copied_from ,
	nre_tablekey_copied_from ,
	not_number_copied_from
  FROM 	notes  
  WHERE	(notes.ntb_table = @table AND notes.nre_tablekey = @key)
	and	IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
			end

IF @table = 'orderheader' and ISNUMERIC(@key) = 1
Insert into #Notes (not_number ,
	not_text ,
	not_type ,
	not_urgent,
	not_senton ,
	not_sentby,
	not_expires ,
	not_forwardedfrom ,
	ntb_table ,
	nre_tablekey ,
	not_sequence ,
	last_updatedby,
	last_updatedatetime ,
	autonote ,
	not_text_large ,
	not_viewlevel ,
	ntb_table_copied_from ,
	nre_tablekey_copied_from ,
	not_number_copied_from)
 SELECT not_number ,
	not_text ,
	not_type ,
	not_urgent,
	not_senton ,
	not_sentby,
	not_expires ,
	not_forwardedfrom ,
	ntb_table ,
	nre_tablekey ,
	not_sequence ,
	last_updatedby,
	last_updatedatetime ,
	autonote ,
	not_text_large ,
	not_viewlevel ,
	ntb_table_copied_from ,
	nre_tablekey_copied_from ,
	not_number_copied_from
  FROM 	notes, TASK  
  WHERE	@table='orderheader'
  AND		notes.ntb_table = 'TASK'  
  AND    	notes.nre_tablekey= Convert (char (12), TASK.TASK_ID)
--AND 		Convert (char (12), TASK.TASK_LINK_ENTITY_SYS_VALUE) =@key
  AND 		TASK.TASK_LINK_ENTITY_SYS_VALUE = convert(int, @key)
	and	IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate())
			end

SELECT n.not_number,   
        	n.not_text,   
        n.not_type,   
        n.not_urgent,   
        n.not_senton,   
        n.not_sentby,   
        n.not_expires,   
        n.not_forwardedfrom,   
        n.ntb_table,   
        n.nre_tablekey,   
        n.not_sequence,   
        n.last_updatedby,   
        n.last_updatedatetime, 
		'            ' ord_number,
		n.autonote,
		--vmj2+	PTS 16582	01/08/2003	This column is used by w_notes_simple to control
		--which rows may be edited..
		'N' as protect_row,
	--PTS 20098
	--PTS 20814  update to logic of 20098 to allow totalmail and loadtender updates to large notes without changing their code
	CASE WHEN ISNULL(n.not_text,'') = ISNULL(SUBSTRING(n.not_text_large,1,254),'') THEN n.not_text_large ELSE CONVERT(text, n.not_text) END not_text,
	--notes.not_text_large,
	--end 20814
	@uselargenotes AS use_large,
	isnull(n.not_viewlevel,''),
	--end PTS 20098
		--vmj2-
        n.ntb_table_copied_from, /*PTS 22790 CGK 8/30/04*/
	n.nre_tablekey_copied_from, /*PTS 22790 CGK 8/30/04*/
	n.not_number_copied_from, /*PTS 22790 CGK 8/30/04*/
	-- PTS 27959 -- BL (start)
--	notes.not_tmsend -- VV22335
	isnull(notes.not_tmsend, '0')
	-- PTS 27959 -- BL (end)
  FROM 	#notes n, notes
  WHERE n.not_number = notes.not_number


GO
GRANT EXECUTE ON  [dbo].[d_notes_sp] TO [public]
GO
