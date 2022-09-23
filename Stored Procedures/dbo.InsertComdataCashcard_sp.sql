SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[InsertComdataCashcard_sp] @crd_number varchar(10), @employee_number varchar(16),
					  @crd_status varchar(1), @crd_act_code varchar(5),
					  @crd_custid varchar(10)
AS

If Substring(@employee_number, 1, 5) = '99999'
 BEGIN
	Select @employee_number = 'UNKNOWN'
 END

If LEN(RTRIM(LTRIM(@crd_custid))) < 5 
 BEGIN
	Select @crd_custid = '0' + @crd_custid
 END

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
 crd_updatestatus)								--18
 
values
(@crd_number, @crd_act_code, @crd_custid, @crd_status,	--1
 'N', 0, 'N', '0',					--2
 'N', 'DRV', @employee_number, '',			--3
 '', '', '', 'UNKNOWN', 				--4
 @employee_number, 'UNKNOWN', '0', '0',			--5
 0, 0, '0', '0',					--6
 '0', '0', '0', '0',					--7
 '0', '0', '0', '0',					--8
 '0', '0', 0, 0,					--9
 0, '0', '0', '0',					--10
 '0', '0', '0', '0',					--11
 '0', '0', '0', 0,					--12
 '0', '0', '0', '0',					--13
 '0', '0', '0', '0',					--14
 '0', 0, '0', '0',					--15
 '0', '0', '0', '0',					--16
 '0', '0', '0', '0',					--17
 'S')


GO
GRANT EXECUTE ON  [dbo].[InsertComdataCashcard_sp] TO [public]
GO
