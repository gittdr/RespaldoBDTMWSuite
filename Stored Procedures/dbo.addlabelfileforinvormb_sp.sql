SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[addlabelfileforinvormb_sp] (@p_format varchar(20),@P_abbr varchar(6),@supportsRollintoLH char(1) = '?')
AS


/*
 * NAME:
 * dbo.addlabelfileforinvormb_sp
 *
 * TYPE:
 * storedprocedure
 *
 * DESCRIPTION:
 * Given the labelfile name and abbr perform the dsb mod for labelfile work for a new invoice or mb format

 * RETURNS:
 *
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - @p_format varchar(20) name if the invoice or mb format (EG d_inv_format134)
 * 002 - @p_abbr varchar(6) labelfile abbr value for the new format
 *       assuems invoice formats will be inv*** and mastebill format will be mb***
 *       @supportsRollintoLH (optional) idicates if format supports rollintoLH (Y, N, ?)  Default is '?'

 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 11/16/07 DPETE PTS39336 DPETE  - Created proc to simplify format db mods going forward
 * 5/1/9 {TS 46930 add indication if format supports rollinto line haul in label_extrastring1
 * 7/2/10 DPETE PTS52842 need to change supports roll inot flag for an existing format using htis proc
 **/ 

  
declare @v_code int

select @p_format = lower(@p_format) /* case in nvo assumes lower */
select @P_abbr = upper(@P_abbr)

select @v_code = 999999999
If left(@p_abbr,3) = 'INV'

  Select  @v_code = (case isnumeric(substring(@p_abbr,4,len(@p_abbr) - 3)) when 1 then convert(int,substring(@p_abbr,4,len(@p_abbr) - 3))
  else @v_code end)

If left(@p_abbr,2) = 'MB'

  select @v_code = case isnumeric(substring(@p_abbr,3,len(@p_abbr) - 2)) 
   when 1 then 100000 + (convert(int,substring(@p_abbr,3,len(@p_abbr) - 2))) * 10
   else (
        case isnumeric (substring(@p_abbr,3,len(@p_abbr) - 3))  
        when 1 then 100000 + (convert(int,substring(@p_abbr,3,len(@p_abbr) - 3))* 10) + 1 
        else @v_code 
        end )
   end

If not exists (select 1 from labelfile where labeldefinition = 'InvoiceSelection'
  and name = @p_format)
  BEGIN
    insert into labelfile (labeldefinition,name,abbr,code,locked,userlabelname,systemcode,retired,inventory_item,
         label_extrastring1)
    values ('InvoiceSelection',@p_format,@p_abbr,@v_code,'Y',@p_format,'Y','N','N',@supportsRollintoLH)
  END
else
  BEGIN
    update labelfile set code = @v_code,userlabelname = @p_format, label_extrastring1 = @supportsRollintoLH
    where labeldefinition = 'InvoiceSelection' and 
    abbr = @p_abbr and
    (code <> @v_code or userlabelname <> @p_format or label_extrastring1 <> @supportsRollintoLH)

    delete from reportobject where dwobjectname = @p_format
  END
GO
GRANT EXECUTE ON  [dbo].[addlabelfileforinvormb_sp] TO [public]
GO
