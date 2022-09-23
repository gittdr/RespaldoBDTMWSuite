SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[insert_new_tch_card_sp] 
		@p_crd_cardnumber	varchar(20),
 		@p_crd_status		char(1),
 		@p_crd_accountid	varchar(10),
 		@p_crd_createddate	datetime

AS

DECLARE	@v_crd_customerid	varchar(10)

/**
 * 
 * NAME:
 * insert_new_tch_card_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Inserts a blank TCH card with a card number and status downloaded via TCH Interactive
 *
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS:  @crd_cardnumber		varchar(20)
 *		@crd_status		char(1)
 *		@crd_accountid		varchar(10)
 *		@crd_createddate	datetime
 *
 * REVISION HISTORY:
 * 3/22/2006.01 ? PTS30817 - Dan Hudec ? Created Procedure
 *
 **/

select	@v_crd_customerid = ccc_id
from	cdcustcode
where	cac_id = @p_crd_accountid

insert into cashcard 
(crd_cardnumber, crd_accountid, crd_customerid, crd_status,			--1
 crd_usecard, crd_directdeposit, crd_atmaccess, crd_vruaccess,			--2
 crd_limitnetworkbycard, asgn_type, asgn_id, crd_firstname,			--3
 crd_lastname, crd_driverlicensenum, crd_driverlicensestate, crd_unitnumber,	--4
 crd_driver, crd_trailernumber, crd_tripnumber, crd_fuelpurchaseyn,		--5
 crd_purchaselimit, crd_onetimepurchaselimit, crd_diesellimit, crd_reeferlimit,	--6
 crd_purchrenewdaily, crd_purchrenewmon, crd_purchrenewtue, crd_purchrenewwed,	--7
 crd_purchrenewthu, crd_purchrenewfri, crd_purchrenewsat, crd_purchrenewsun,	--8
 crd_purchrenewtrip, crd_expcashflagyn, crd_cashlimit, crd_onetimecashlimit,	--9
 crd_cashbalance, crd_cashrenewdaily, crd_cashrenewmon, crd_cashrenewtue,	--10
 crd_cashrenewwed, crd_cashrenewthu, crd_cashrenewfri, crd_cashrenewsat,	--11
 crd_cashrenewsun, crd_cashrenewtrip, crd_phoneserviceyn, crd_phoneamountlimit,	--12
 crd_phonerenewdaily, crd_phonerenewsun, crd_phonerenewmon, crd_phonerenewtue,	--13
 crd_phonerenewwed, crd_phonerenewthu, crd_phonerenewfri, crd_phonerenewsat,	--14
 crd_phonerenewtrip, crd_oilamountlimit, crd_oillimit, crd_oilrenewdaily,	--15
 crd_oilrenewsun, crd_oilrenewmon, crd_oilrenewtue, crd_oilrenewwed,		--16
 crd_oilrenewthu, crd_oilrenewfri, crd_oilrenewsat, crd_oilrenewtrip,		--17
 crd_updatestatus, crd_createddate)						--18
 
values
(@p_crd_cardnumber, @p_crd_accountid, @v_crd_customerid, @p_crd_status,	--1
 'N', 0, 'N', '0',							--2
 'N', 'DRV', 'UNKNOWN', '',						--3
 '', '', '', 'UNKNOWN', 						--4
 'UNKNOWN', 'UNKNOWN', '0', '0',					--5
 0, 0, '0', '0',							--6
 '0', '0', '0', '0',							--7
 '0', '0', '0', '0',							--8
 '0', '0', 0, 0,							--9
 0, '0', '0', '0',							--10
 '0', '0', '0', '0',							--11
 '0', '0', '0', 0,							--12
 '0', '0', '0', '0',							--13
 '0', '0', '0', '0',							--14
 '0', 0, '0', '0',							--15
 '0', '0', '0', '0',							--16
 '0', '0', '0', '0',							--17
 'S', @p_crd_createddate)							--18

GO
GRANT EXECUTE ON  [dbo].[insert_new_tch_card_sp] TO [public]
GO
