SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[Set_TaxFlag3_on_companies] (@p_cmpid varchar(8), @p_val char(1),@p_state varchar(6),@p_country varchar(50) )

AS

/**
 * 
 * NAME:
 * Set_TaxFlag3_on_companies
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION: Sets the company tax flag 3 to the value in @p_val (only if Y or N) on bill to companies only
 *    To set for one company:  exec Set_TaxFlag3_on_companies 'MYCMPID','Y','',''
 *    To set for one Province(state) :  exec Set_TaxFlag3_on_companies 'UNKNOWN','Y','PQ',''
 *    To set for all Province(state) in the country :  exec Set_TaxFlag3_on_companies 'UNKNOWN','Y','','CANADA'  
 *      *** must have records in the statecountry table for all Provinces or States within the country

 * 
 * RETURNS: NONE
 *
 * RESULT SETS: \
 * none
 *
 * PARAMETERS: @p_cmpid	varchar(8) 'UNKNOWN' to set tax code on for all bill to companies; pass a code and flag is set for that company only 
 * @p_val set to "Y" to set flag on , "N" to set flag off.  If any other value is passed nothing will be done
 * @p_state varchar(6) if set, update bill to companies for that state or province only
 * @p_country varchar(50) if set , update all bill to companies in that country only (rerquires an entry in the statecountry table with that coutnry in the stc_coutnry_c
 *
 * REVISION HISTORY:
 * 11/28/2006.01 ? PTS35284 - DPETE ? Created Procedure
 *
 **/
SET NOCOUNT ON



declare @v_next varchar (8),@v_nextstate varchar(6)
select @p_val = upper(@p_val),@v_next = '',@p_state = upper(@p_state),@p_country = upper(@p_country)

If @p_val <> 'Y' and @p_val <> 'N' Return


If @p_cmpid <> 'UNKNOWN' and @p_cmpid <> ''
   update company
   set  cmp_taxtable3   = @p_val
   where cmp_id = @p_cmpid 
   and (cmp_taxtable3 is null or cmp_taxtable3 <> @p_val) 
   and cmp_billto = 'Y'
else
 BEGIN
 if @p_state  <> 'ALL' ANd @p_state <> ''
   BEGIN
     Select @v_next = min(cmp_id) from company where  cmp_state = @p_state and cmp_billto = 'Y'
     While @v_next is not null
       BEGIN
         update company
         set cmp_taxtable3   = @p_val
         where cmp_id = @v_next
         and (cmp_taxtable3 is null or cmp_taxtable3 <> @p_val) 

         select @v_next = min(cmp_id) from company where cmp_id > @v_next and cmp_state = @p_state and cmp_billto = 'Y'
       END
    END
  else
    if @p_country <> '' and @p_country <> 'ALL'
      BEGIN  --country loop
       select @v_nextstate = min(stc_state_c) from statecountry where stc_country_c = @p_country
       While @v_nextstate is not null
         BEGIN  -- state loop
           Select @v_next = min(cmp_id) from company where  cmp_state = @v_nextstate and cmp_billto = 'Y'
           While @v_next is not null
             BEGIN  -- company loop
               update company
               set cmp_taxtable3   = @p_val
               where cmp_id = @v_next
               and (cmp_taxtable3 is null or cmp_taxtable3 <> @p_val) 


               select @v_next = min(cmp_id) from company where cmp_id > @v_next and cmp_state = @v_nextstate and cmp_billto = 'Y'
             END -- company loop
             select @v_nextstate = min(stc_state_c) from statecountry where stc_country_c = @p_country and stc_state_c > @v_nextstate
          END -- state loop
        END -- country loop
 END



GO
GRANT EXECUTE ON  [dbo].[Set_TaxFlag3_on_companies] TO [public]
GO
