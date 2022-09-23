SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


/*
 PTS 23188 - DJM - Stored proc created to create/update a note on the Order that
	displays the Phone number of the Third Party attached to the Order.
	Called from Orderheader insert/update trigger (it_ordersave) and controlled by 
	Generalinfo setting: AutoCreateTPRNote = 'Y'
*/

CREATE PROC [dbo].[create_tpr_order_note_sp]
        @ord_hdrnumber int, 
	@thirdpartyid	varchar(8),
	@note_is_urgent char(1)
	
	
AS

DECLARE  @note_sequence int, 
	@ntb_table varchar(18), 
	@not_urgent char(1), 
	@not_number int, 
	@nre_tablekey int,
	@tpr_phone1	varchar(10),
	@tpr_fax	varchar(10),
	@tpr_name	varchar(30),
	@applies_to	varchar(30),
	@note		varchar(256),
 	@old_thirdpartyid	varchar(8),
	@tpr_secondary	varchar(30),
	@GI_NUMBEROFDAYSFORNOTEEXPstring1 varchar (30),--PTS 48225 KPM 4/20/2010
	@gi_NUMBEROFDAYSFORNOTEEXPint1 int,--PTS 48225 KPM 4/20/2010
	@not_expires datetime,--PTS 48225 KPM 4/20/2010
	@orderenddate datetime


 
  
SELECT @nre_tablekey = @ord_hdrnumber

IF @ord_hdrnumber IS NULL RETURN 

/* Determine the Phone number of the 'Agent'. Use the ord_thirdpartytype1
	column to look up record from the ThirdPartyProfile table	
*/
if not exists (select tpr_id from thirdpartyprofile, orderheader 
		where orderheader.ord_hdrnumber = @ord_hdrnumber 
			and orderheader.ord_thirdpartytype1 = thirdpartyprofile.tpr_id)
	Return

select @tpr_phone1 = tpr_primaryphone,
	@tpr_fax = tpr_faxphone,
	@tpr_name = tpr_name,
	@tpr_secondary = tpr_secondaryphone
from thirdpartyprofile t
where t.tpr_id = @thirdpartyid

/* PTS 48225 KPM 4/20/2010 need use note epxiration GI setting when auto inserting note. */
select @orderenddate = ord_dest_latestdate
from orderheader 
where @ord_hdrnumber = ord_hdrnumber

select 	@GI_NUMBEROFDAYSFORNOTEEXPstring1 = ISNULL (gi_string1, ''),
		@gi_NUMBEROFDAYSFORNOTEEXPint1 = ISNULL (Gi_integer1, 0)
from generalinfo 
where gi_name = 'NUMBEROFDAYSFORNOTEEXP'

select @not_expires = '12/31/2049 23:59:00'

if (@GI_NUMBEROFDAYSFORNOTEEXPstring1 = '' or @GI_NUMBEROFDAYSFORNOTEEXPstring1 = 'C') and  @gi_NUMBEROFDAYSFORNOTEEXPint1 > 0
select @not_expires = dateadd (day, @gi_NUMBEROFDAYSFORNOTEEXPint1, getdate())


if  @GI_NUMBEROFDAYSFORNOTEEXPstring1 = 'E' and  @gi_NUMBEROFDAYSFORNOTEEXPint1 > 0 and @orderenddate < convert (datetime, '12/31/2049', 101) 
select @not_expires = dateadd (day,  @gi_NUMBEROFDAYSFORNOTEEXPint1, @orderenddate)
/* END PTS 48225 */


/* Format the Note Text		*/
select @note = 'Agent: ' + isNull(@tpr_name,'(None)') + Char(13)+ Char(10)
select @note = @note + 'Agent ID: ' + RTrim(isNull(@thirdpartyid,'(None)')) + Char(13)+ Char(10)
select @note = @note + 'Phone: ' + @tpr_phone1 + Char(13)+ Char(10)
select @note =  @note + 'Secondary Phone: ' + @tpr_secondary + Char(13)+ Char(10)
select @note = @note + 'Fax: ' + @tpr_fax + Char(13)+ Char(10)


SELECT @ntb_table = 'orderheader'

SELECT @not_urgent = 
	CASE UPPER(ISNULL(@note_is_urgent,''))
	WHEN 'Y' THEN 'A'
	ELSE 'N'
END

select @applies_to = isNull(gi_string2,'NONE')
from generalinfo
where gi_name = 'AutoCreateTPRNote' and Left(gi_string1,1) = 'Y'

SELECT @applies_to = UPPER(@applies_to)
IF LEN(RTRIM(@applies_to)) = 0 SELECT @applies_to = 'NONE' 

EXEC @not_number = dbo.getsystemnumber 'NOTES',NULL

SELECT @note_sequence = MAX(not_sequence)
FROM notes
WHERE ntb_table = @ntb_table
	AND   nre_tablekey = @nre_tablekey

IF @note_sequence IS NULL 
	SELECT @note_sequence = 1
ELSE
	SELECT @note_sequence = @note_sequence + 1

INSERT 
INTO notes (
	not_number, not_text, not_type,                       --1
	not_urgent,  ntb_table,                   --2
	nre_tablekey, not_sequence, last_updatedby,            --3
	last_updatedatetime,                                   --4
	not_expires)										   --5
VALUES (
	@not_number, @note, @applies_to,                       --1
	@not_urgent, @ntb_table,              --2
	@nre_tablekey, @note_sequence, suser_sname(),          --3
	getdate(),                                              --4
	@not_expires)										   --5	

IF @@error<>0
BEGIN
	EXEC tmw_log_error 888, 'Update TPR Note Failed', @@error, @ord_hdrnumber
	return -1
END

 
GO
GRANT EXECUTE ON  [dbo].[create_tpr_order_note_sp] TO [public]
GO
