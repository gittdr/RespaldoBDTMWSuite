SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[getleg_loadedmiles] @leg_number int, @lded_miles int output

AS
/**
 * 
 * NAME:
 * dbo.getleg_loadedmiles 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * pts 2526 L.R.
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/

DECLARE @currleg_num int,
        @currord_num int,
        @currmov_num int,
        @nonbillable_stp int,
        @NBS_arrdate datetime,
        @commcol_ord int

select @currleg_num = 0
select @currord_num = 0 
select @currmov_num = 0

-- plug in the VALUE OF leg number here. 
select @currleg_num = @leg_number

-- initialise the nonbillable stops on leg
select @nonbillable_stp = 0


select @nonbillable_stp = stp_number
from event
where evt_eventcode IN ('BMT', 'BBT', 'HMT')
and stp_number IN (select stp_number
                   from stops
                   where lgh_number = @currleg_num)


-- NO non billable stops then all legmiles is billable
if @nonbillable_stp = 0
begin
  /*select " all the legmiles are loaded and is billed"*/
  select @lded_miles = sum(stp_lgh_mileage)
  from stops
  where lgh_number = @currleg_num
end

-- Find the arrival date at nonbillable stop
if @nonbillable_stp > 0
begin
   select @NBS_arrdate = stp_arrivaldate
   from stops
   where stp_number = @nonbillable_stp
 
-- use the NonBillableStop arrival date to get to stop which contains the nonbillable miles.
select @NBS_arrdate = min(stp_arrivaldate)
from stops
where stp_arrivaldate > @NBS_arrdate
and stp_number != @nonbillable_stp
and lgh_number = @currleg_num

-- use that arrivaldate to get to billable miles stated in the next stop on leg.
select @lded_miles = sum(stp_lgh_mileage)
from stops 
where stp_arrivaldate > @NBS_arrdate
and stp_number != @nonbillable_stp
and lgh_number = @currleg_num
end

select @lded_miles = IsNull(@lded_miles,0)

return @lded_miles


GO
GRANT EXECUTE ON  [dbo].[getleg_loadedmiles] TO [public]
GO
