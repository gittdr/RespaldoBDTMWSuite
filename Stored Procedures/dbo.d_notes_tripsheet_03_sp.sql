SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_notes_tripsheet_03_sp] (@table char(18), @key char(18))
AS

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

SELECT	

  		notes.ntb_table,   
       	notes.nre_tablekey,   
        	notes.not_text      

/*	notes.not_number,   
        notes.not_text,   
        notes.not_type,   
        notes.not_urgent,   
        notes.not_senton,   
        notes.not_sentby,   
        notes.not_expires,   
        notes.not_forwardedfrom,   
        notes.timestamp,   
        notes.ntb_table,   
        notes.nre_tablekey,   
        notes.not_sequence,   
        notes.last_updatedby,   
        notes.last_updatedatetime, 
		'            ' ord_number,
		autonote,
		--vmj2+	PTS 16582	01/08/2003	This column is used by w_notes_simple to control
		--which rows may be edited..
		'N' as protect_row,
	--PTS 20098
	--PTS 20814  update to logic of 20098 to allow totalmail and loadtender updates to large notes without changing their code
	CASE WHEN ISNULL(notes.not_text,'') = ISNULL(SUBSTRING(notes.not_text_large,1,254),'') THEN notes.not_text_large ELSE CONVERT(text, notes.not_text) END not_text,
	--notes.not_text_large,
	--end 20814
	@uselargenotes AS use_large,
	isnull(not_viewlevel,'')
	--end PTS 20098
		--vmj2-
*/
  FROM 	notes  
  WHERE	(notes.ntb_table = @table AND notes.nre_tablekey = @key)
	and	IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
			end


GO
GRANT EXECUTE ON  [dbo].[d_notes_tripsheet_03_sp] TO [public]
GO
