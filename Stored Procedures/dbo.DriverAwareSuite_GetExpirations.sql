SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO











CREATE           Proc [dbo].[DriverAwareSuite_GetExpirations]
	(
	@LowExpirationDt 	datetime,
	@HighExpirationDt 	datetime,
	@OnlyDriverTypes1 	varchar(255) ='',
	@OnlyDriverTypes2 	varchar(255) ='',
	@OnlyDriverTypes3 	varchar(255)='',
	@OnlyDriverTypes4 	varchar(255)='',
	@OnlyDriverTeamLeaders 	varchar(255)='',
	@OnlyDriverTerminals 	varchar(255)='',
	@onlyCompletedStatuses	Varchar(255)='',
	@onlyPriorityCodes	Varchar(255)='',
	@onlyExpCodes		Varchar(255)='',
	@OnlyDriverIDs	  	varchar(4000)='',
	@ExcludeExpCodes  	varchar(255)=''		
	)
AS


	Set @OnlyDriverTypes1= ',' + ISNULL(rtrim(@OnlyDriverTypes1),'') + ','
	Set @OnlyDriverTypes2= ',' + ISNULL(rtrim(@OnlyDriverTypes2),'') + ','
	Set @OnlyDriverTypes3= ',' + ISNULL(rtrim(@OnlyDriverTypes3),'') + ','
	Set @OnlyDriverTypes4= ',' + ISNULL(rtrim(@OnlyDriverTypes4),'') + ','


	Set @OnlyDriverTeamLeaders= ',' + ISNULL(rtrim(@OnlyDriverTeamLeaders),'') + ','
	Set @OnlyDriverTerminals= ',' + ISNULL(rtrim(@OnlyDriverTerminals),'') + ','

	Set @onlyCompletedStatuses = ',' + ISNULL(rtrim(@onlyCompletedStatuses),'') + ','
	Set @onlyPriorityCodes = ',' + ISNULL(rtrim(@onlyPriorityCodes),'') + ','

	Set @onlyExpCodes = ',' + ISNULL(rtrim(@onlyExpCodes),'') + ','

	Set @OnlyDriverIDs = ',' + ISNULL(rtrim(@OnlyDriverIDs),'') + ','
	Set @ExcludeExpCodes = ',' + ISNULL(rtrim(@ExcludeExpCodes),'') + ','

	--Select @OnlyDriverTypes1

Select 
	exp_key,
	exp_id,
	exp_expirationdate,
	IsNull(exp_compldate,exp_expirationdate) exp_compldate ,
	exp_code,
	exp_codeName=IsNull((Select name from labelfile where labeldefinition='DrvExp' and abbr=exp_code),''),
	exp_completed,
	exp_priority, 
	IsNull(exp_description,'') exp_description ,
	ISNull(exp_city,0) exp_city,
	exp_CityName= ISNULL ( (Select cty_nmstct from city where city.cty_code=exp_city),'UNKNOWN') ,
	ISNULL(exp_routeto,'') exp_routeto ,
	exp_RouteToName= ISNULL( (Select cmp_name from company where exp_routeto=cmp_id),'UNKNOWN') ,
	exp_updateby,
	exp_updateon,
	exp_creatdate,
	case when exp_idtype = 'DRV'  Then
		(select mpp_lastfirst from manpowerprofile (NOLOCK) where mpp_id = exp_id)		
	else
		''
	end as DriverName,
	TipText=
	IsNull('Driver ID/Name: ' + exp_id + '/' +
	case when exp_idtype = 'DRV'  Then
		(select mpp_lastfirst from manpowerprofile (NOLOCK) where mpp_id = exp_id)		
	else
		''
	end + Char(13) + Char(13) + 
	'Expiration ID/Name: ' + IsNull(exp_code,'') + '/' + IsNull((Select name from labelfile where labeldefinition='DrvExp' and abbr=exp_code),'') + Char(13) + Char(13) + 
	'Dates: ' + convert(varchar (10),exp_expirationdate,101) + ' ' + 
                 Left(convert(varchar (10),exp_expirationdate,108),Len(convert(varchar (10),exp_expirationdate,108))-3) + ' - ' + convert(varchar (10),exp_compldate,101) + ' ' + 
                 Left(convert(varchar (10),exp_compldate,108),Len(convert(varchar (10),exp_compldate,108))-3) + Char(13) + Char(13) + 
	'Completed Y/N: ' + IsNull(exp_completed,'') + Char(13) + Char(13) + 
	'Priority Level: ' + IsNull((Select IsNull(name,'') from labelfile (NOLOCK) where   labeldefinition='ExpPriority' and abbr = exp_priority),'')  + Char(13) + Char(13) + 
	'Description: ' + IsNull(exp_description,'') + Char(13) + Char(13) + 
	'Location ID/Name: ' + ISNULL(exp_routeto,'') + '/' + ISNULL( (Select cmp_name from company where exp_routeto=cmp_id),'') + Char(13) + Char(13) + 
	'City,State: ' + ISNULL ( (Select cty_nmstct from city where city.cty_code=exp_city),'')
	     ,''),
	LabelCode = IsNull((Select Top 1 code from labelfile where labeldefinition='DrvExp' and abbr=exp_code),0),
	CreateMove = 'N'--IsNull((Select Top 1 create_move from labelfile where labeldefinition='DrvExp' and abbr=exp_code),'N')

from 	expiration e (NOLOCK),
	ManpowerProfile m (NOLOCK)
where 
	exp_idtype='Drv' 
	and 
	(exp_expirationdate< DateAdd(day,1,@HighExpirationDt) and exp_compldate>=@LowExpirationDt)
	and
	mpp_id=exp_id 
	and
	mpp_terminationdt>=@LowExpirationDt
	AND (@OnlyDriverTypes1 =',,' or CHARINDEX(',' + mpp_type1 + ',', @OnlyDriverTypes1) >0)
	AND (@OnlyDriverTypes2 =',,' or CHARINDEX(',' + mpp_type2 + ',', @OnlyDriverTypes2) >0)
	AND (@OnlyDriverTypes3 =',,' or CHARINDEX(',' + mpp_type3 + ',', @OnlyDriverTypes3) >0)
	AND (@OnlyDriverTypes4 =',,' or CHARINDEX(',' + mpp_type4 + ',', @OnlyDriverTypes4) >0)

	AND (@OnlyDriverTeamLeaders =',,' or CHARINDEX(',' + mpp_teamleader + ',', @OnlyDriverTeamLeaders) >0)
	AND (@OnlyDriverTerminals =',,' or CHARINDEX(',' + mpp_terminal + ',', @OnlyDriverTerminals) >0)

	AND (@onlyCompletedStatuses =',,' or CHARINDEX(',' + exp_completed + ',', @onlyCompletedStatuses) >0)
	AND (@onlyPriorityCodes =',,' or CHARINDEX(',' + exp_priority + ',', @onlyPriorityCodes) >0)
	AND (@onlyExpCodes =',,' or CHARINDEX(',' + exp_code + ',', @onlyExpCodes) >0)
	AND (@OnlyDriverIDs =',,' or CHARINDEX(',' + mpp_id + ',', @OnlyDriverIDs) >0)

	AND (@ExcludeExpCodes =',,' or CHARINDEX(',' + exp_code + ',', @ExcludeExpCodes) =0)

Order by exp_id,exp_expirationdate

/*
UNION
Select 
	exp_key,
	exp_id,
	exp_expirationdate,
	IsNull(exp_compldate,exp_expirationdate) exp_compldate ,
	exp_code,
	exp_codeName=IsNull((Select name from labelfile where labeldefinition='DrvExp' and abbr=exp_code),''),
	exp_completed,
	exp_priority, 
	IsNull(exp_description,'') exp_description ,

	ISNull(exp_city,0) exp_city,
	exp_CityName= ISNULL ( (Select cty_nmstct from city where city.cty_code=exp_city),'') ,
	ISNULL(exp_routeto,'') exp_routeto ,
	exp_RouteToName= ISNULL( (Select cmp_name from company where exp_routeto=cmp_id),'') ,
	exp_updateby,
	exp_updateon,
	exp_creatdate,
	case when exp_idtype = 'DRV'  Then
		(select mpp_lastfirst from manpowerprofile (NOLOCK) where mpp_id = exp_id)		
	else
		''
	end as DriverName,
	TipText=
        IsNull('DriverID: ' + exp_id + Char(13) + 
	'Expiration Name: ' + IsNull((Select name from labelfile where labeldefinition='DrvExp' and abbr=exp_code),'') + Char(13) +
	'Dates: ' + convert(varchar(20),exp_expirationdate,101) + ' - ' + convert(varchar(20),exp_compldate,101) + Char(13) + 
	'Location: ' + ISNULL ( (Select cty_nmstct from city where city.cty_code=exp_city),'')
	     ,'')
from 	expiration e (NOLOCK),
	ManPowerProfile m (NOLOCK)
where 
	exp_idtype='Drv' 
	and 
	exp_expirationdate <@LowExpirationDt
	And 
	exp_compldate >@LowExpirationDt
	and
	mpp_id=exp_id 
	and
	mpp_terminationdt>=@LowExpirationDt
	AND (@OnlyDriverTypes1 =',,' or CHARINDEX(',' + mpp_type1 + ',', @OnlyDriverTypes1) >0)
	AND (@OnlyDriverTypes2 =',,' or CHARINDEX(',' + mpp_type2 + ',', @OnlyDriverTypes2) >0)
	AND (@OnlyDriverTypes3 =',,' or CHARINDEX(',' + mpp_type3 + ',', @OnlyDriverTypes3) >0)
	AND (@OnlyDriverTypes4 =',,' or CHARINDEX(',' + mpp_type4 + ',', @OnlyDriverTypes4) >0)

	AND (@OnlyDriverTeamLeaders =',,' or CHARINDEX(',' + mpp_teamleader + ',', @OnlyDriverTeamLeaders) >0)
	AND (@OnlyDriverTerminals =',,' or CHARINDEX(',' + mpp_terminal + ',', @OnlyDriverTerminals) >0)

	AND (@onlyCompletedStatuses =',,' or CHARINDEX(',' + exp_completed + ',', @onlyCompletedStatuses) >0)
	AND (@onlyPriorityCodes =',,' or CHARINDEX(',' + exp_priority + ',', @onlyPriorityCodes) >0)
	AND (@onlyExpCodes =',,' or CHARINDEX(',' + exp_code + ',', @onlyExpCodes) >0)
	AND (@OnlyDriverIDs =',,' or CHARINDEX(',' + mpp_id + ',', @OnlyDriverIDs) >0)

	AND (@ExcludeExpCodes =',,' or CHARINDEX(',' + exp_code + ',', @ExcludeExpCodes) =0)
	

*/




















GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetExpirations] TO [public]
GO
