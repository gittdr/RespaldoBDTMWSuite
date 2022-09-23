SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


--WatchDogGetParameterDefault 'Blackhawk_RevPerMileGTThreshold',''
CREATE procedure [dbo].[WatchDogGetParameterDefault]
(
	@WatchName varchar(255), 
	@ParmName varchar(500)
)
AS
	SET NOCOUNT ON

	Declare @SQL varchar(4000)
	Declare @ProcedureName varchar(255)

	Create Table #tempresults ([text] varchar(4000))

	SELECT * INTO #WatchdogParameter FROM WatchdogParameter WITH (NOLOCK) WHERE SubHeading = @WatchName AND parametername = @ParmName

	Set @ProcedureName = (select top 1 sqlstatement from watchdogitem WITH (NOLOCK) where watchname = @WatchName)

	Insert into #tempresults ([text])
	select top 1 c.text 
	FROM  sysobjects o WITH (NOLOCK) INNER JOIN syscomments c WITH (NOLOCK) ON o.id = c.id
	WHERE o.type = 'p' AND o.name = @ProcedureName 
	ORDER BY colid

	select ParameterName, [Default] = (select top 1	substring(text,
								charindex(ParameterName,text)+ 
								charindex('=', substring(
											text,charindex(ParameterName,text),len(text))),
			
								charindex(',',substring(text,charindex(ParameterName,text)+1+ 
								charindex('=', substring(
													text,charindex(ParameterName,text),len(text))),len(text))))
	 from #tempresults ),
	[Default2] = (select top 1	substring(text,
								charindex(ParameterName,text)+ 
								charindex('=', substring(
											text,charindex(ParameterName,text),len(text))),
			
								charindex('@',substring(text,charindex(ParameterName,text)+1+ 
								charindex('=', substring(
													text,charindex(ParameterName,text),len(text))),len(text))))
	 from #tempresults ),
	[Default3] = (select top 1	substring(text,
								charindex(ParameterName,text)+ 
								charindex('=', substring(
											text,charindex(ParameterName,text),len(text))),
			
								charindex(')',substring(text,charindex(ParameterName,text)+1+ 
								charindex('=', substring(
													text,charindex(ParameterName,text),len(text))),len(text))))
	 from #tempresults )
	into #tempresults2
	from #WatchdogParameter -- where subheading = @WatchName
	-- and parametername not in ('@ColumnMode','@ColumnNamesOnly','@executedirectly') order by parametersort


	update #tempresults2
	set default2 = '''''', default3 = ''''''
	where [default]= '''''' or [default] = ' ''''' 

	update #tempresults2
	set default3 = 'DEFAULT2'
	where default3 like '%@%'

	update #tempresults2
	set [default]=''
	where [default]like'%=%'

	update #tempresults2
	set default2=''
	where default2 like '%=%'

	update #tempresults2
	set default2 = (
	substring(default2, charindex('''',default2),charindex('''',substring(default2,charindex('''',default2)+1,len(default2)))+1)
	--from #tempresults2
	--where default2=default2
	)
	where default2 like '%''%'

	select parametername, [Default] as [Default]
	into #TempResults3
	from #TempResults2
	where [default] not like '''' and [default] not like '%''%' and [default] <> ''

	insert into #TempResults3
	select parametername, default3 as [default]
	from #tempresults2
	where [default] = '' and default2='' and default3<>''


	insert into #TempResults3
	select parametername, Default2 as [Default]
	from #TempResults2
	where default2 like '%''%' or default2 like '%''''%' and default2 not like '%)%'


	select [default] from #tempresults3
	where parametername = @ParmName

GO
GRANT EXECUTE ON  [dbo].[WatchDogGetParameterDefault] TO [public]
GO
