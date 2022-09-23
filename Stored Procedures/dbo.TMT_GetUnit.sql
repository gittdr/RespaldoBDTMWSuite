SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[TMT_GetUnit]
@unit varchar(12)
as
/**
*
* NAME:
* dbo.TMT_GetUnit
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Get unit information from Transman
*
* RETURNS:
* Transman unit info.
* RESULT SETS:
* none.
*
* PARAMETERS:
* 	@unit - Transman unit id/
*
* REVISION HISTORY:
* 12/10/2005 - MRH – Created
*
**/

Declare @shoplink int
Declare @sql 			varchar(5000),
@tmtserver		varchar(25),
@tmtdb			varchar(25)

SELECT @shoplink =
COUNT(1)
FROM generalinfo
where gi_name = 'Shoplink' and
gi_integer1 > 0

IF @shoplink = 0 return                 -- SHOPLINK NOT Installed

SET ANSI_NULLS ON
set ANSI_WARNINGS ON

IF ISNULL((select gi_string1 from generalinfo where gi_name = 'Shoplink'), '') <> ''
BEGIN
select @tmtserver = '[' + gi_string1 + ']' from generalinfo where gi_name = 'Shoplink'
select @tmtdb = '[' + gi_string2 + ']' from generalinfo where gi_name = 'Shoplink'
SET @SQL= 'SELECT CAST(UNITNUMBER as VARCHAR(12)) AS UNITID,DESCRIP,FLEETID,DOMICILE,COSTCTCODE,DEPTCODE,ACTIVCODE,'+
'DIVISIONCD,GROUPSID, ISTIRE, STATUS,TYPE,MAKE,MODEL,MODELYEAR,LICENSE, '+
'CAST(PARTID AS VARCHAR(24)) as PARTID,MFGPARTID,SERIALNO,TITLE,ENGINE,CAPACITY,WHEELBASE,PRESSURE,CAST(CUSTID AS VARCHAR(12)) AS CUSTOMERID,INSERVICE,WARRLIFE1, '+
'WARRLIFE2,WARRLIFE3,METERDEF1,METERDEF2,METERDEF3,PARENTMTR,PURCHFROM,PURCHPRICE,'+
'PURCHUOM,DEPRBASE,MONTHDEPR,YEARDEPR,TOTALDEPR,ACTIVECODE,OBJTYPE, '+
'OBJID,MODIFIED,MODIFIEDBY,DEPPERIOD,VENDOR,COMPANYUNIT, PHYLOCATION, PHYSHOPLOCATION, '+
'LOANERUNIT,UNITUSERFLD1, UNITUSERFLD2, UNITUSERFLD3, UNITUSERFLD4,ASSETNUM,UNITWEIGHT, PARKFACILITY,'+
'PARKFACILITYNAME,PARKSLOT,COLOR,SALVAGEVALUE,EMPDRVID,UNITUSERFLD5, UNITUSERFLD6, UNITUSERFLD7, '+
'UNITUSERFLD8 FROM ' + @tmtserver + '.' + @tmtdb + '.dbo.VIEW_UNITS WHERE UNITNUMBER = ''' + @UNIT + ''''
--select @SQL,@tmtserver

EXEC (@SQL)
END
ELSE
BEGIN
select @tmtdb = '[' + gi_string2 + ']' from generalinfo where gi_name = 'Shoplink'
SET @SQL= 'SELECT * FROM ' + @tmtdb + '.dbo.VIEW_UNITS WHERE UNITNUMBER = ''' + @UNIT + ''''
EXEC (@SQL)
END
SET ANSI_NULLS OFF
set ANSI_WARNINGS OFF

GO
GRANT EXECUTE ON  [dbo].[TMT_GetUnit] TO [public]
GO
