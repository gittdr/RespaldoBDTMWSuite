SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* DPETE PTS22154 4/8/4 (Paul's Hauling) Need to specify by company what may be picked up or delivered.
   For pickups only, specify product characterisitcs (density). This proc creates a record for the data specified
   if that data does not exist

*/
CREATE PROCEDURE [dbo].[makecompanyproduct_sp] @cmpid varchar(8),@pupdrp char(3),@cmdcode varchar(8),
  @subcode varchar(8),@density decimal(9,4), @startmonth tinyint, @startday tinyint,
  @endmonth tinyint, @endday tinyint
AS

Declare @ret int
Select @ret = 0

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

If not Exists(Select cpr_identity From companyproduct
  Where cmp_id = @cmpid
  And cpr_pup_or_drp = @pupdrp
  And cmd_code = @cmdcode
  And scm_subcode = @subcode
  And cpr_startmonth = @startmonth
  And cpr_startday = @startday
  And cpr_endmonth = @endmonth
  And cpr_endday = @endday)
  BEGIN
   Insert into companyproduct(
   cmp_id
   ,cpr_pup_or_drp
   ,cmd_code
   , scm_subcode
   , cpr_startmonth
   , cpr_startday
   , cpr_endmonth
   , cpr_endday
   , cpr_updateby
   , cpr_updatedate
   , cpr_density)
   Values(
   @cmpid
   , @pupdrp
   , @cmdcode
   , @subcode
   , @startmonth
   , @startday
   , @endmonth
   , @endday
   , @tmwuser
   , getdate()
   , @density
   )

   Select @ret = 1
  END
Return @ret

GO
GRANT EXECUTE ON  [dbo].[makecompanyproduct_sp] TO [public]
GO
