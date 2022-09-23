SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[create_edi_notify_refnumbers] (@ord_hdrnumber INTEGER, @notify_party VARCHAR(30),  
           @notify_phone VARCHAR(30), @notify_fax VARCHAR(30))        
AS          
    
DECLARE    
@ref_type_notify_party VARCHAR(6),    
@ref_type_notify_phone VARCHAR(6),    
@ref_type_notify_fax VARCHAR(6),    
@ref_count INT,    
@ref_typedesc_notify_party VARCHAR(8),    
@ref_typedesc_notify_phone VARCHAR(8),    
@ref_typedesc_notify_fax VARCHAR(8),    
@ref_sequence_notify_party INT,    
@ref_sequence_notify_phone INT,    
@ref_sequence_notify_fax INT,    
@max_ref_sequence INT
    
SELECT @ref_type_notify_party = gi_string1,          
       @ref_type_notify_fax = gi_string2,        
    @ref_type_notify_phone = gi_string3        
  FROM generalinfo          
 WHERE gi_name = 'RailBillingTenderNotifyType'    
     
SELECT @ref_typedesc_notify_party = (SELECT TOP 1 name FROM labelfile    
 WHERE labeldefinition = 'ReferenceNumbers' and abbr = @ref_type_notify_party)    
    
--SELECT @ref_typedesc_notify_phone = (SELECT TOP 1 name FROM labelfile    
-- WHERE labeldefinition = 'ReferenceNumbers' and abbr = @ref_type_notify_phone)       
    
SELECT @ref_typedesc_notify_fax = (SELECT TOP 1 name FROM labelfile    
 WHERE labeldefinition = 'ReferenceNumbers' and abbr = @ref_type_notify_fax)     
     
SELECT @ref_sequence_notify_party = (SELECT TOP 1 ref_sequence from referencenumber WHERE ord_hdrnumber = @ord_hdrnumber    
  and ref_table = 'orderheader' and ref_type = @ref_type_notify_party)    
      
--SELECT @ref_sequence_notify_phone = (SELECT TOP 1 ref_sequence from referencenumber WHERE ord_hdrnumber = @ord_hdrnumber    
--  and ref_table = 'orderheader' and ref_type = @ref_type_notify_phone)    
     
SELECT @ref_sequence_notify_fax = (SELECT TOP 1 ref_sequence from referencenumber WHERE ord_hdrnumber = @ord_hdrnumber    
  and ref_table = 'orderheader' and ref_type = @ref_type_notify_fax)      
     
SELECT @ref_count = (SELECT count(*) FROM referencenumber    
 WHERE ref_table = 'orderheader' and ord_hdrnumber = @ord_hdrnumber)    
    
SELECT @max_ref_sequence = IsNull(max(ref_sequence),0) FROM referencenumber    
 WHERE ref_table = 'orderheader' and ord_hdrnumber = @ord_hdrnumber    
    
if @ref_count = 0 and @max_ref_sequence = 0    
 begin   
  
  if @ref_type_notify_party is not null and @notify_party is not null   
  begin    
   INSERT into referencenumber (ref_tablekey,ref_type,ref_number,ref_typedesc,ref_sequence,ord_hdrnumber,ref_table)    
   VALUES(@ord_hdrnumber,@ref_type_notify_party,@notify_party,@ref_typedesc_notify_party,1,@ord_hdrnumber,'orderheader')  
  end  
    
--  if @ref_type_notify_phone is not null and @notify_phone is not null   
--  begin      
--   INSERT into referencenumber (ref_tablekey,ref_type,ref_number,ref_typedesc,ref_sequence,ord_hdrnumber,ref_table)    
--   VALUES(@ord_hdrnumber,@ref_type_notify_phone,@notify_phone,@ref_typedesc_notify_phone,2,@ord_hdrnumber,'orderheader')    
--  end  
  
  if @ref_type_notify_fax is not null and @notify_fax is not null   
  begin     
   INSERT into referencenumber (ref_tablekey,ref_type,ref_number,ref_typedesc,ref_sequence,ord_hdrnumber,ref_table)    
   VALUES(@ord_hdrnumber,@ref_type_notify_fax,@notify_fax,@ref_typedesc_notify_fax,2,@ord_hdrnumber,'orderheader')    
  end     
    
  if @ref_type_notify_party is not null and @notify_party is not null   
   begin   
   UPDATE orderheader    
   set ord_refnum = @notify_party,    
    ord_reftype = @ref_type_notify_party    
   where ord_hdrnumber = @ord_hdrnumber
   end   
  else  
--   if @ref_type_notify_phone is not null and @notify_phone is not null  
--    begin   
--    UPDATE orderheader    
--    set ord_refnum = @notify_phone,    
--    ord_reftype = @ref_type_notify_phone    
--    where ord_hdrnumber = @ord_hdrnumber  
--  end  
--  else  
    if @ref_type_notify_fax is not null and @notify_fax is not null  
    begin   
    UPDATE orderheader    
    set ord_refnum = @notify_fax,    
    ord_reftype = @ref_type_notify_fax    
    where ord_hdrnumber = @ord_hdrnumber
  end 
end    
else    
 begin    
  if @ref_sequence_notify_party is not null and @ref_sequence_notify_party > 0    
   begin    
    update referencenumber    
    set ref_number = @notify_party    
    where ord_hdrnumber = @ord_hdrnumber    
    and ref_table = 'orderheader'    
    and ref_type = @ref_type_notify_party    
    and ref_sequence = @ref_sequence_notify_party;  
      
    if @ref_sequence_notify_party = 1  
    begin  
      UPDATE orderheader    
	  set ord_refnum = @notify_party,    
      ord_reftype = @ref_type_notify_party    
      where ord_hdrnumber = @ord_hdrnumber
    end  
   end     
  else    
   begin    
    SELECT @max_ref_sequence = @max_ref_sequence + 1    
    INSERT into referencenumber (ref_tablekey,ref_type,ref_number,ref_typedesc,ref_sequence,ord_hdrnumber,ref_table)    
    VALUES(@ord_hdrnumber,@ref_type_notify_party,@notify_party,@ref_typedesc_notify_party,@max_ref_sequence,@ord_hdrnumber,'orderheader')     
   end 
   
  
--  if @ref_sequence_notify_phone is not null and @ref_sequence_notify_phone > 0    
--   begin    
--    update referencenumber    
--    set ref_number = @notify_phone    
--    where ord_hdrnumber = @ord_hdrnumber    
--    and ref_table = 'orderheader'    
--    and ref_type = @ref_type_notify_phone    
--    and ref_sequence = @ref_sequence_notify_phone;  
--      
--    if @ref_sequence_notify_phone = 1  
--    begin  
--      UPDATE orderheader    
--   set ord_refnum = @notify_phone,    
--      ord_reftype = @ref_type_notify_phone    
--      where ord_hdrnumber = @ord_hdrnumber    
--    end    
--   end  
--       
--  else    
--   begin    
--    SELECT @max_ref_sequence = @max_ref_sequence + 1    
--    INSERT into referencenumber (ref_tablekey,ref_type,ref_number,ref_typedesc,ref_sequence,ord_hdrnumber,ref_table)    
--    VALUES(@ord_hdrnumber,@ref_type_notify_phone,@notify_phone,@ref_typedesc_notify_phone,@max_ref_sequence,@ord_hdrnumber,'orderheader')    
--   end    
       
  if @ref_sequence_notify_fax is not null and @ref_sequence_notify_fax > 0    
   begin    
    update referencenumber    
    set ref_number = @notify_fax    
    where ord_hdrnumber = @ord_hdrnumber    
    and ref_table = 'orderheader'    
    and ref_type = @ref_type_notify_fax    
    and ref_sequence = @ref_sequence_notify_fax;  
      
    if @ref_sequence_notify_fax = 1  
    begin  
      UPDATE orderheader    
      set ord_refnum = @notify_fax,    
      ord_reftype = @ref_type_notify_fax    
      where ord_hdrnumber = @ord_hdrnumber 
    end      
   end    
  else    
   begin    
    SELECT @max_ref_sequence = @max_ref_sequence + 1    
    INSERT into referencenumber (ref_tablekey,ref_type,ref_number,ref_typedesc,ref_sequence,ord_hdrnumber,ref_table)    
    VALUES(@ord_hdrnumber,@ref_type_notify_fax,@notify_fax,@ref_typedesc_notify_fax,@max_ref_sequence,@ord_hdrnumber,'orderheader')    
   end    
 end    

declare @mov int

select @mov = mov_number from orderheader where ord_hdrnumber = @ord_hdrnumber

exec update_move @mov

GO
GRANT EXECUTE ON  [dbo].[create_edi_notify_refnumbers] TO [public]
GO
