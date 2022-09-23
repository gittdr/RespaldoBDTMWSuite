SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Assign_Third_Party_Defaults_sp] (@mov int)
AS 
set nocount on
set ansi_warnings off      ---  supress any truncation messages (for total mail)

/*----------------------------------------------------------------------------------------------------------------------
PTS 52591 JSwindell  6/2010             Assign Third party defaults to NEW Orders added from OE or from Dispatch.  
                                                     ( This code does not update thirdpartyassignment ANY (non-deleted) assignments already exist )
                                                     CALLED FROM  Update_move, Update_move_light, Update_ord.  
                                                     {original code was duplicated in these 3 procs: -- MRH 30923 -- Third party default assignments} 
                                                     -- PTS 52591 Change to original functionality:  IF GI setting is on - only assign TPR's
                                                     -- who have the SAME revtype as the Order.  
                                                     -- GI setting to look at is: ThirdPartyRevTypeCol gi_string1 & gi_string2   
                                                     -- IF GI is set - The only place we need to look at the ThirdParty Restrictions are on the INSERT statements.
                                                     -- Add new requirment (if trackbranch on)  7-22-2010
                                                     -- 7-25-2010: Additional work.
PTS 62520  LOR,      added tpr_split, tpr_split_flag
PTS 85473  BW, 12/22/2014,  Added code to take into account ThirdPartyType1,ThirdPartyType2,ThirdPartyType3,ThirdPartyType4 columns.
*/---------------------------------------------------------------------------------------------------------------------------------------

DECLARE @lgh               int
DECLARE @ord_number        char(12)
DECLARE @ord_billto        char(8)
DECLARE @tpr_id                  varchar(8)
DECLARE @tprel_number_count  int 
DECLARE @tpr_assigned_to_order_NOTDEL  int 
DECLARE @tpr_assigned_to_order_DEL  int 
-- pts 52591 - new req: 
declare @trackbranch             CHAR(1)
SELECT       @trackbranch = UPPER(ISNULL(LEFT(gi_string1, 1), 'N'))
FROM   generalinfo
WHERE  gi_name = 'TrackBranch'

Select @lgh = min(lgh_number) 
from stops 
where ord_hdrnumber = (SELECT MIN(ord_hdrnumber) FROM stops WHERE mov_number = @mov and ord_hdrnumber <> 0)

select @ord_number = ord_number, @ord_billto = ord_billto 
from orderheader 
where ord_hdrnumber = (SELECT MIN(ord_hdrnumber) FROM stops WHERE mov_number = @mov and ord_hdrnumber <> 0)


-- 36019 BDH:  If the existing auto assigned 3rd party is not the current billto, mark them deleted.
if (select count(0) from thirdpartyassignment 
       where ord_number = @ord_number 
       and tpa_status = 'AUTO' 
       and tpr_id not in (select tpr_id 
                                    from thirdpartyrelationship 
                                    where tprel_table = 'company.billto' and tprel_tablekey = @ord_billto)) > 0
begin                      
       update thirdpartyassignment set tpa_status = 'DEL'
       where ord_number = @ord_number 
       and tpa_status = 'AUTO' 
       and tpr_id not in (select tpr_id 
                                    from thirdpartyrelationship 
                                    where tprel_table = 'company.billto' and tprel_tablekey = @ord_billto)
end

-- pts 52591 New functionality  SET UP ==============================
DECLARE @ord_hdrnumber int                           -- PTS 52591
DECLARE @ThirdPartyRevTypeCol varchar(60)      -- PTS 52591
DECLARE @TPRProfile_REVTYPE_VALUE   varchar(12)    -- PTS 52591* (-- PTS 52591* ord_booked_revtype1 is 12x(???), ord_revtype1-4 are 6x.)

DECLARE @ORDERRevTypeCol      varchar(60)      -- PTS 52591
DECLARE @ORDER_revtype_x     varchar(10) -- PTS 52591
DECLARE @OrderHeader_REVTYPE_VALUE  varchar(12)    -- PTS 52591* ord_booked_revtype1 is 12x(???), ord_revtype1-4 are 6x.
Declare @type1 varchar(6)                            -- PTS 52591
Declare @type2 varchar(6)                            -- PTS 52591
Declare @type3 varchar(6)                            -- PTS 52591
Declare @type4 varchar(6)                            -- PTS 52591
-- pts 52591 - new req: 
Declare @typebookded varchar(12)               -- PTS 52591 ord_booked_revtype1 is 12x as is tpr_branch is 12x
                                                                                                                        

---select @ThirdPartyRevTypeCol = gi_string1 , @ORDERRevTypeCol = gi_string2  we will only use string1 -- pts 52591 - new req: 
select @ThirdPartyRevTypeCol = gi_string1 , @ORDERRevTypeCol = gi_string1
from generalinfo 
where gi_name = 'ThirdPartyRevTypeCol'

-- in case there is garbage in the gi_string1
IF (  LEN( LTRIM(RTRIM(@ThirdPartyRevTypeCol)) ) <= 0 OR LTRIM(RTRIM(@ThirdPartyRevTypeCol)) = 'UNK'  OR LTRIM(RTRIM(@ThirdPartyRevTypeCol)) = 'UNKNOWN' ) 
begin
       set @ThirdPartyRevTypeCol = NULL 
end


-- the gi_string2 item for order rev is OPTIONAL.  
-- If gi_string1 is set and 2 is not, then we default them to be the same revtype.
IF ( LEN(@ORDERRevTypeCol) <= 0  OR @ORDERRevTypeCol is NULL ) AND LEN(@ThirdPartyRevTypeCol) > 0 
begin
       set @ORDERRevTypeCol = @ThirdPartyRevTypeCol
end

-- set the ORDER revtype based on the gi_string2 setting (IF it is set at all).
IF LEN(@ORDERRevTypeCol) > 0 
begin
       if charindex('1', @ORDERRevTypeCol, 1) > 0 
       begin  
             set @ORDER_revtype_x = 'revtype1'
       end
       if charindex('2', @ORDERRevTypeCol, 1) > 0 
       begin  
             set @ORDER_revtype_x = 'revtype2'
       end
       if charindex('3', @ORDERRevTypeCol, 1) > 0 
       begin  
             set @ORDER_revtype_x = 'revtype3'
       end
       if charindex('4', @ORDERRevTypeCol, 1) > 0 
       begin  
             set @ORDER_revtype_x = 'revtype4'
       end
       if CHARINDEX('booked', @ORDERRevTypeCol, 1) > 0
       begin  
             set @ORDER_revtype_x = 'booked'
       end    
end

-- PTS 52591 new req:  trackbranch.
IF @trackbranch <> 'Y' AND @ORDER_revtype_x = 'booked'
       BEGIN 
             set @ORDER_revtype_x = NULL
             set @ThirdPartyRevTypeCol = NULL 
       END 
       
----------  7-25-2010:  Since users can, at will via the GI setting, change their restriction column, 
----------  test to see if the restriction values match the currently selected items.  If not, update them.

create table #temp_tpr_restr (tpr_id varchar(8) null, restr_type varchar(12)null, revtype1 varchar(12)null, 
                                                 revtype2 varchar(12)null, revtype3 varchar(12)null, 
                                                 revtype4 varchar(12)null, branch varchar(12)null, 
                                                 tprel_restriction varchar(12)null ) 

IF LEN( @ORDER_revtype_x ) > 0
BEGIN
       declare @ll_badcount int

       --insert into #temp_tpr_restr (tpr_id, restr_type, revtype1, revtype2, revtype3, revtype4, branch, tprel_restriction) 
       --select distinct p.tpr_id, @ORDER_revtype_x, p.tpr_revtype1, p.tpr_revtype2, p.tpr_revtype3, p.tpr_revtype4, p.tpr_branch, r.tprel_restriction
       --from thirdpartyprofile p join thirdpartyrelationship r on p.tpr_id = r.tpr_id 
       --where r.tprel_table = 'company.billto' and r.tprel_tablekey =  @ord_billto             
       
       insert into #temp_tpr_restr (tpr_id, restr_type, revtype1, revtype2, revtype3, revtype4, branch, tprel_restriction) 
       select distinct p.tpr_id,
                    @ORDER_revtype_x,
                    isnull(p.tpr_revtype1,'UNK') 'revtype1', 
                    isnull(p.tpr_revtype2,'UNK') 'revtype2', 
                    isnull(p.tpr_revtype3,'UNK') 'revtype3', 
                    isnull(p.tpr_revtype4,'UNK') 'revtype4', 
                    isnull(p.tpr_branch,'UNK') 'branch', 
                    isnull(r.tprel_restriction,'UNK') 'tprel_restriction' 
       from thirdpartyprofile p join thirdpartyrelationship r on p.tpr_id = r.tpr_id 
       where r.tprel_table = 'company.billto' and r.tprel_tablekey =  @ord_billto             
              
       
       set @ll_badcount = 0       
       IF @ORDER_revtype_x = 'booked'
       begin 
                    select @ll_badcount = ( select count(*) from #temp_tpr_restr where upper(Ltrim(Rtrim(tprel_restriction))) <> upper(LTRIM(rtrim(branch))) )   
                           IF @ll_badcount > 0 
                           begin                      
                                 update thirdpartyrelationship 
                                 set tprel_restriction = (select thirdpartyprofile.tpr_branch from thirdpartyprofile where thirdpartyprofile.tpr_id = thirdpartyrelationship.tpr_id) 
                                 where  thirdpartyrelationship.tprel_table = 'company.billto' 
                                 and thirdpartyrelationship.tprel_tablekey = @ord_billto
                           end 
             
       end
       
       set @ll_badcount = 0       
       IF @ORDER_revtype_x = 'revtype1'
       begin 
                    select @ll_badcount = ( select count(*) from #temp_tpr_restr where upper(Ltrim(Rtrim(tprel_restriction))) <> upper(LTRIM(rtrim(revtype1))) ) 
                           IF @ll_badcount > 0 
                           begin                      
                                 update thirdpartyrelationship 
                                 set tprel_restriction = (select thirdpartyprofile.tpr_revtype1 from thirdpartyprofile where thirdpartyprofile.tpr_id = thirdpartyrelationship.tpr_id) 
                                 where  thirdpartyrelationship.tprel_table = 'company.billto' 
                                 and thirdpartyrelationship.tprel_tablekey = @ord_billto
                           end 
             
       end
       
       set @ll_badcount = 0       
       IF @ORDER_revtype_x = 'revtype2'
       begin 
                    select @ll_badcount = ( select count(*) from #temp_tpr_restr where upper(Ltrim(Rtrim(tprel_restriction))) <> upper(LTRIM(rtrim(revtype2))) ) 
                           IF @ll_badcount > 0 
                           begin                      
                                 update thirdpartyrelationship 
                                 set tprel_restriction = (select thirdpartyprofile.tpr_revtype2 from thirdpartyprofile where thirdpartyprofile.tpr_id = thirdpartyrelationship.tpr_id) 
                                 where  thirdpartyrelationship.tprel_table = 'company.billto' 
                                 and thirdpartyrelationship.tprel_tablekey = @ord_billto
                           end 
             
       end
       
       set @ll_badcount = 0       
       IF @ORDER_revtype_x = 'revtype3'
       begin 
                    select @ll_badcount = ( select count(*) from #temp_tpr_restr where upper(Ltrim(Rtrim(tprel_restriction))) <> upper(LTRIM(rtrim(revtype3))) ) 
                           IF @ll_badcount > 0 
                           begin                      
                                 update thirdpartyrelationship 
                                 set tprel_restriction = (select thirdpartyprofile.tpr_revtype3 from thirdpartyprofile where thirdpartyprofile.tpr_id = thirdpartyrelationship.tpr_id) 
                                 where  thirdpartyrelationship.tprel_table = 'company.billto' 
                                 and thirdpartyrelationship.tprel_tablekey = @ord_billto
                           end 
             
       end
       
       set @ll_badcount = 0       
       IF @ORDER_revtype_x = 'revtype4'
       begin 
                    select @ll_badcount = ( select count(*) from #temp_tpr_restr where upper(Ltrim(Rtrim(tprel_restriction))) <> upper(LTRIM(rtrim(revtype4))) ) 
                           IF @ll_badcount > 0 
                           begin                      
                                 update thirdpartyrelationship 
                                 set tprel_restriction = (select thirdpartyprofile.tpr_revtype4 from thirdpartyprofile where thirdpartyprofile.tpr_id = thirdpartyrelationship.tpr_id) 
                                 where  thirdpartyrelationship.tprel_table = 'company.billto' 
                                 and thirdpartyrelationship.tprel_tablekey = @ord_billto
                           end 
             
       end
       
       
END
----------  7-25-2010:  end

select @ord_hdrnumber = (SELECT MIN(ord_hdrnumber) FROM stops WHERE mov_number = @mov and ord_hdrnumber <> 0)

-- ord_booked_revtype1 is 12x(???), ord_revtype1-4 are 6x
select  @type1 = ord_revtype1, 
             @type2 = ord_revtype2, 
             @type3 = ord_revtype3, 
             @type4 = ord_revtype4, 
             -----@typebookded = cast(ord_booked_revtype1 as varchar(6)) 
             @typebookded = ord_booked_revtype1
from   orderheader 
where  ord_hdrnumber = @ord_hdrnumber

set  @OrderHeader_REVTYPE_VALUE = 
             case @ORDER_revtype_x
                    when 'revtype1' then @type1
                    when 'revtype2' then @type2
                    when 'revtype3' then @type3
                    when 'revtype4' then @type4
                    when 'booked' then @typebookded 
                    --else NULL
                    else 'UNK'
             end    --end case

-- pts 52591 New functionality  END OF SET UP ==============================

-- BDH 36019 5/14/07 - Check that the 3rd party is active and if he's auto assigned on the tpassignment count and insert.
-- 36019 BDH.  Inserting pyd_status = 'NPD' instead of null.
-- If he's already in there with a status of DEL, do not auto assign him again.
-- PTS 44064 JSwindell 10/27/2008 - don't duplicate 'auto assigned 3rd parties' on a copy 

-- Count the ACTIVE TPR relationships for this billto
set @tprel_number_count = ( select count(tprel_number) 
                                               from thirdpartyrelationship, thirdpartyprofile
                                               where tprel_table = 'company.billto' 
                                               and tprel_tablekey = @ord_billto
                                               and thirdpartyprofile.tpr_id = thirdpartyrelationship.tpr_id                                            
                                               and isnull(tpr_active, 'Y') = 'Y')       
                                               
IF @tprel_number_count > 0 
BEGIN 
-- if there ARE some ACTIVE TPR  relationships for this billto and they are not yet assigned for this order - add them.

       if (select count(0) from thirdpartyassignment 
             where ord_number = @ord_number 
             and (tpa_status = 'AUTO' or tpa_status = 'AUTOCC') 
             and tpa_status <> 'DEL') = 0 
             AND
          (select count(0) from thirdpartyassignment 
           where ord_number = @ord_number 
           and tpa_status = 'DEL' and tpr_id in (select tpr_id
                                                                           from thirdpartyrelationship 
                                                                           where tprel_table = 'company.billto' 
                                                                           and tprel_tablekey = @ord_billto)) = 0

             begin  
                           
                    --IF LEN(@ThirdPartyRevTypeCol) <= 0 
                      IF @ThirdPartyRevTypeCol IS NULL  OR ( LEN(@ThirdPartyRevTypeCol) > 0  AND ISNULL(@OrderHeader_REVTYPE_VALUE, 'UNK')  = 'UNK' )
                           begin                            
                           -- Normal Unrestricted Insert  
                                insert into thirdpartyassignment
								(tpr_id, lgh_number, mov_number, tpa_status, pyd_status, tpr_type, ord_number, tpr_split, tpr_split_flag,
								 ThirdPartyType1,ThirdPartyType2,ThirdPartyType3,ThirdPartyType4)
								select TPRS.tpr_id, @lgh, @mov, 'AUTO', 'NPD', TPRS.tpr_type, @ord_number , TPRS.tpr_split, TPRS.tpr_split_flag,
									   TPRP.ThirdPartyType1,TPRP.ThirdPartyType2, TPRP.ThirdPartyType3, TPRP.ThirdPartyType4
								from thirdpartyrelationship TPRS
								inner join dbo.thirdpartyprofile TPRP
									ON (TPRS.tpr_id = TPRP.tpr_id)
								where (TPRS.tprel_table = 'company.billto') 
								  and (TPRS.tprel_tablekey = @ord_billto);		                
                                                         
                                 RETURN -- if we've done the insert, we're done, get out.
                           end 
                                 
                    IF LEN(@ThirdPartyRevTypeCol) > 0 
                           begin                            
                           -- additional restriction for -- PTS 52591                  
                                insert into thirdpartyassignment
								(tpr_id, lgh_number, mov_number, tpa_status, pyd_status, tpr_type, ord_number, tpr_split, tpr_split_flag,
								ThirdPartyType1,ThirdPartyType2,ThirdPartyType3,ThirdPartyType4)
								select TPRS.tpr_id, @lgh, @mov, 'AUTO', 'NPD', TPRS.tpr_type, @ord_number , TPRS.tpr_split, TPRS.tpr_split_flag,
									   TPRP.ThirdPartyType1,TPRP.ThirdPartyType2, TPRP.ThirdPartyType3, TPRP.ThirdPartyType4
								from thirdpartyrelationship TPRS
								inner join dbo.thirdpartyprofile TPRP
									ON (TPRS.tpr_id = TPRP.tpr_id)
								where (TPRS.tprel_table = 'company.billto') 
								and (TPRS.tprel_tablekey = @ord_billto)
								and ISNULL(TPRS.tprel_restriction, 'UNK') IN ('UNK', @OrderHeader_REVTYPE_VALUE);        
                                 
                                 --RETURN     -- if we've done the insert, we're done, get out.                                              
                           end    
                                 
             end 

RETURN -- if we've done the insert, we're done, get out.    
END


IF @tprel_number_count = 0 
BEGIN 
set @tpr_assigned_to_order_NOTDEL  =  (select count(0) from thirdpartyassignment 
                                                                   where ord_number = @ord_number 
                                                                   and tpa_status <> 'DEL' 
                                                                   and tpr_id in (select tpr_id 
                                                                                          from thirdpartyrelationship 
                                                                                          where tprel_table = 'company.billto' 
                                                                                          and tprel_tablekey = @ord_billto))  


set @tpr_assigned_to_order_DEL = (select count(0) from thirdpartyassignment 
                                                       where ord_number = @ord_number 
                                                       and tpa_status = 'DEL' 
                                                       and tpr_id in ( select tpr_id 
                                                                                  from thirdpartyrelationship 
                                                                                  where tprel_table = 'company.billto' 
                                                                                  and tprel_tablekey = @ord_billto))

END 

--IF @tpr_assigned_to_order_NOTDEL + @tpr_assigned_to_order_DEL = 0 
IF IsNull(@tpr_assigned_to_order_NOTDEL, 0) + IsNull(@tpr_assigned_to_order_DEL, 0) = 0          --     LOR    PTS# 62520
BEGIN
       --No matches found the billto probably changed.
                           -- Delete the existing that were not manually added and add the default
                           update thirdpartyassignment set tpa_status = 'DEL' 
                           where ord_number = @ord_number and tpa_status <> 'DEL' 
                           and tpa_status = 'AUTO'
                           
                           --IF LEN(@ThirdPartyRevTypeCol) <= 0 
                           IF @ThirdPartyRevTypeCol IS NULL
                           begin                            
                           -- Normal Unrestricted Insert                  
                                 insert into thirdpartyassignment
									(tpr_id, lgh_number, mov_number, tpa_status, pyd_status, tpr_type, ord_number, tpr_split, tpr_split_flag,
									 ThirdPartyType1,ThirdPartyType2,ThirdPartyType3,ThirdPartyType4)
									select TPRS.tpr_id, @lgh, @mov, 'AUTO', 'NPD', TPRS.tpr_type, @ord_number , TPRS.tpr_split, TPRS.tpr_split_flag,
										   TPRP.ThirdPartyType1,TPRP.ThirdPartyType2, TPRP.ThirdPartyType3, TPRP.ThirdPartyType4
									from thirdpartyrelationship TPRS
									inner join dbo.thirdpartyprofile TPRP
										ON (TPRS.tpr_id = TPRP.tpr_id)
									where (TPRS.tprel_table = 'company.billto' )
									  and (TPRS.tpr_id IS NOT NULL)
									  and (TPRS.tprel_tablekey = @ord_billto);
                           end
                    IF LEN(@ThirdPartyRevTypeCol) > 0 
                           begin                            
                           -- additional restriction for -- PTS 52591                        
                                insert into thirdpartyassignment
								(tpr_id, lgh_number, mov_number, tpa_status, pyd_status, tpr_type, ord_number, tpr_split, tpr_split_flag,
								 ThirdPartyType1,ThirdPartyType2,ThirdPartyType3,ThirdPartyType4)
								select TPRS.tpr_id, @lgh, @mov, 'AUTO', 'NPD', TPRS.tpr_type, @ord_number, TPRS.tpr_split, TPRS.tpr_split_flag, 
									TPRP.ThirdPartyType1, TPRP.ThirdPartyType2, TPRP.ThirdPartyType3, TPRP.ThirdPartyType4
								from thirdpartyrelationship TPRS
								inner join dbo.thirdpartyprofile TPRP
									ON (TPRS.tpr_id = TPRP.tpr_id)
								where (TPRS.tprel_table = 'company.billto') 
								  and (TPRS.tpr_id IS NOT NULL)
								  and (TPRS.tprel_tablekey = @ord_billto)
								  and ISNULL(TPRS.tprel_restriction, 'UNK') IN ('UNK', @OrderHeader_REVTYPE_VALUE)	;	                                                                                  
                           end                 
                                                     
END  
GO
GRANT EXECUTE ON  [dbo].[Assign_Third_Party_Defaults_sp] TO [public]
GO
DECLARE @xp float
SELECT @xp=1
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'PROCEDURE', N'Assign_Third_Party_Defaults_sp', NULL, NULL
GO
