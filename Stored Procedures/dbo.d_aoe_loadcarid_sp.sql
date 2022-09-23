SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*  PTS 16760 - DJM - Created to allow enforcement of the Carrier/User security
	feature of Agent Order Entry.  Proc checks the association of the current 
	user with Carrier codes.
*/

CREATE PROC [dbo].[d_aoe_loadcarid_sp] @comp varchar(8) , @number int AS

/* PTS12130 MBR 10/10/01 Added grace period check */
DECLARE @daysout int,
                  @date datetime
--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

SELECT @daysout = -90

--vjh 31536
if exists ( SELECT lbp_id FROM ListBoxProperty where lbp_id=@@spid)
select @daysout = lbp_daysout, 
	@date = lbp_date
	from ListBoxProperty
	where lbp_id=@@spid
else
SELECT @daysout = gi_integer1,
               @date = gi_date1
   FROM  generalinfo
WHERE gi_name = 'GRACE'

if @daysout <> 999
   SELECT @date = dateadd(day, @daysout, getdate())

if @number = 1 
	set rowcount 1 
else if @number <= 8 
	set rowcount 8
else if @number <= 16
	set rowcount 16
else if @number <= 24
	set rowcount 24
else
	set rowcount 8

if @comp <> 'UNKNOWN' and exists ( SELECT car_id 
                  FROM carrier 
               WHERE car_id LIKE @comp + '%'  AND
                             (car_status <> 'OUT' OR (car_status = 'OUT' AND car_terminationdt >= @date))) 
	SELECT car_name , car_id , car_address1 , car_address2 , cty_nmstct, car_board 
	  FROM carrier, city, user_asset_restrictions uar
	 WHERE car_id LIKE @comp + '%' AND
              (car_status <> 'OUT' OR (car_status = 'OUT' AND car_terminationdt >= @date)) AND
	       carrier.cty_code = city.cty_code
		and uar.uar_asgnid = car_id
		and uar.uar_asgntype = 'CAR'
		and uar.usr_userid = @tmwuser
	Union
	SELECT car_name , car_id , car_address1 , car_address2 , cty_nmstct, car_board 
	  FROM carrier, city, user_asset_restrictions uar, ttsgroupasgn
	 WHERE car_id LIKE @comp + '%' AND
              (car_status <> 'OUT' OR (car_status = 'OUT' AND car_terminationdt >= @date)) AND
	       carrier.cty_code = city.cty_code
		and uar.uar_asgnid = car_id
		and uar.uar_asgntype = 'CAR'
		and uar.usr_userid = ttsgroupasgn.grp_id
		and ttsgroupasgn.usr_userid = @tmwuser
	ORDER BY car_id 
else 
	SELECT car_name , car_id , car_address1 , car_address2 , 'UNKNOWN', 'Y'
		FROM carrier
		WHERE car_id = 'UNKNOWN' 
set rowcount 0 



GO
GRANT EXECUTE ON  [dbo].[d_aoe_loadcarid_sp] TO [public]
GO
