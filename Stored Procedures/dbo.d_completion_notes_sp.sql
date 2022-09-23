SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
  
CREATE PROC [dbo].[d_completion_notes_sp] (@table char(18), @key char(18))  
AS  
  
declare @ord_number varchar(12)  
declare @showexpired char(1)  
declare @grace integer  
declare @uselargenotes char(1) 
declare @noteKey varchar(18) 
  
select @showexpired =isnull(gi_string1,'Y')  
from generalinfo  
where gi_name = 'showexpirednotes'  
  
select @grace =isnull(gi_integer1,0)  
from generalinfo  
where gi_name = 'showexpirednotesgrace'  
  
select @uselargenotes = isnull(gi_string1,'N')  
from generalinfo  
where gi_name = 'uselargenotes'  

select @noteKey = Convert(varchar, @key)
  
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
  FROM  notes    
  WHERE (notes.ntb_table = @table AND notes.nre_tablekey = @Key)  
	and IsNull(DATEADD(day, @grace, not_expires), getdate()) >=   
			case @showexpired   
				when 'N' then getdate()  
				else  IsNull(DATEADD(day, @grace, not_expires), getdate())   
			end  
  
IF @table = 'orderheader'  
BEGIN

--CJB - Deal with conversion of int to string for index.
SELECT @noteKey = Convert(varchar, min(ivh_hdrnumber)) from invoiceheader --JD added min PTS 37341 
          WHERE  ord_hdrnumber = Convert(int, @key)
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
  FROM  notes  
  WHERE @table='orderheader'  
  AND  notes.ntb_table = 'invoiceheader'    
  AND  notes.nre_tablekey = @noteKey
  AND  notes.not_type in ('CV_KIE', 'CV_KIW')  
 AND IsNull(DATEADD(day, @grace, not_expires), getdate()) >=   
		   case @showexpired   
				when 'N' then getdate()  
				else  IsNull(DATEADD(day, @grace, not_expires), getdate())  
		   end  
END
  
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
		'N' as protect_row,  
	CASE WHEN ISNULL(n.not_text,'') = ISNULL(SUBSTRING(n.not_text_large,1,254),'') THEN n.not_text_large ELSE CONVERT(text, n.not_text) END not_text,  
	@uselargenotes AS use_large,  
	isnull(n.not_viewlevel,''),  
	n.ntb_table_copied_from,  
	n.nre_tablekey_copied_from,  
	n.not_number_copied_from,  
	isnull(notes.not_tmsend, '0')  
  FROM  #notes n, notes  
  WHERE n.not_number = notes.not_number  
  
 
GO
GRANT EXECUTE ON  [dbo].[d_completion_notes_sp] TO [public]
GO
