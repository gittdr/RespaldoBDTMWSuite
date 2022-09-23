SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[refnbrseplist_fn] 
  (@p_table varchar(50)
  ,@p_reftablekey int
  ,@p_withtypes char(1)
  ,@p_sep char(1)
  ,@p_type1 varchar(6)
  ,@p_type2 varchar(6)
  ,@p_type3 varchar(6)
  ,@p_type4 varchar(6))
RETURNS varchar(1000)
AS
/*
 * NAME:
 * dbo.refnbrseplist_fn 
 *
 * TYPE:
 * function
 *
 * DESCRIPTION:
 * Create a string with a list of referencenumbers

 * RETURNS:
 * varchar(100)  separated list of refeencenumbers
 *
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - @p_table varchar(50) ref_table value
 * ,@p_reftablekey int  ref_tablekey value
 * ,@p_withtypes char(1)  Y to include types
 * ,@p_sep char(1)   separater character
 * ,@p_type1 varchar(6)  ref_type if ALL the all refs returned
 * ,@p_type2 varchar(6)  (or) second ref type
 * ,@p_type3 varchar(6)   (or) third ref type
 * ,@p_type4 varchar(6)   (or) fourth ref type
 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 9/26/07 DPETE PTS38049 DPETE  - Created function to be called from proc

 *
 **/ 
BEGIN
   DECLARE @v_reflist varchar(1000)
   select @v_reflist = ''
 ,@p_type1 = isnull(@p_type1,'') 
 ,@p_type2 =isnull(@p_type2,'')
, @p_type3 =isnull(@p_type3,'')
 ,@p_type4 =isnull(@p_type4,'')

   select @v_reflist = @v_reflist
      + case @p_withtypes when 'Y' then ref_type+' ' else '' end 
      +ref_number+@p_sep+' '
   from referencenumber 
   where ref_table = @p_table and
   ref_tablekey = @p_reftablekey and
   (ref_type in (@p_type1,@p_type2,@p_type3,@p_type4) or @p_type1 = 'ALL')
   if len(@v_reflist) > 3 select @v_reflist = substring(@v_reflist,1,len(@v_reflist) -2 )

   RETURN @v_reflist
END
GO
GRANT EXECUTE ON  [dbo].[refnbrseplist_fn] TO [public]
GO
GRANT REFERENCES ON  [dbo].[refnbrseplist_fn] TO [public]
GO
