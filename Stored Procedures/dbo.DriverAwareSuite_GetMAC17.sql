SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE    Procedure [dbo].[DriverAwareSuite_GetMAC17]

As


Declare @ServerName varchar(255)
Declare @DatabaseName varchar(255)

Declare @SQL nvarchar(4000)
Declare @SQLDyn varchar(2500)
Declare @Prefix varchar(1000)
Declare @ConnectionServerName varchar(255)
Declare @HoursOfServiceFormID varchar(255)

Set @Prefix = ''

Set @HoursOfServiceFormID = IsNull((select cast(dsat_value as int) from DriverAwareSuite_GeneralInfo where dsat_type = 'TotalMail' and dsat_key = 'HoursOfServiceFormID'),'36')

CREATE TABLE #TractorTemp (
	FormID int NULL ,
	Contents varchar (2048) NULL ,
	SN int NULL ,
	DTsent varchar (11) NULL ,
	NLCPosition varchar (50) NULL ,
	PositionZip varchar (9)  NULL ,
	--Errored int NULL ,
	--ErrorDesc varchar (8000)  NOT NULL ,
	Name varchar (25) NULL ,
	fromname varchar (50) NULL 
) 

If Left(Substring(@@version,23,4),1) = '7'
    Begin
		select @ConnectionServerName = RTRIM(CONVERT(varchar(60), @@servername))
		FROM master..sysdatabases WHERE dbid = (SELECT dbid FROM master..sysprocesses WHERE spid = @@spid)
	End
	Else
	Begin
		select @ConnectionServerName = RTRIM(CONVERT(varchar(60), CASE WHEN cmptlevel = '70' THEN @@servername ELSE SERVERPROPERTY('servername') END))
		FROM master..sysdatabases WHERE dbid = (SELECT dbid FROM master..sysprocesses WHERE spid = @@spid)
	End

Set @SQL = 'Select @ServerName = gi_string1 from generalinfo where gi_name = ' +
'''' + 'TOTALMAIL' + ''''
Exec sp_executesql @SQL,N'@ServerName varchar(200) output',@ServerName output
Set @SQL = 'Select @DatabaseName = gi_string2 from generalinfo where gi_name = ' +
'''' + 'TOTALMAIL' + ''''
Exec sp_executesql @SQL,N'@DatabaseName varchar(200) output',@DatabaseName output
If Len(@DatabaseName) > 0
Begin
	Set @Prefix = Case When Len(@ServerName) > 0 And @ConnectionServerName <> @ServerName Then @ServerName + '.' + @DatabaseName + '.' Else @DatabaseName + '.' End
End



Delete from DriverAwareSuite_Mac17

Set @SQLDyn = 'select  distinct frm.FormID, ' + 
 ' convert(varchar(2048),Msg.DTSent) Contents,   ' + 
 'frm.Version SN,  ' + 
 'Convert(varchar(5), Msg.DTSent,1) + ' + '''' + ' ' + '''' + ' + Convert(varchar(5),Msg.DTSent, 8) DTsent, ' + 
 'NLCPosition, ' +   
 'PositionZip,  ' + 
 /*'Errored =  (Select count(*) '/ +
 'from  cledev.snbctmlive.dbo.tblMsgProperties Errorprp ' +
 'where Msg.SN=Errorprp.msgsn and Errorprp.PropSN = 6), ' +
 'ErrorDesc=  ISNULL( (Select Replace ( Replace(convert(varchar(512),Description),char(10), '|') , char(13), '|') Description  '
     ' From       cledev.snbctmlive.dbo.tblErrorData ErrTbl, ' + 
     ' cledev.snbctmlive.dbo.tblMsgProperties Errorprp ' +   
     ' where   Msg.SN=Errorprp.msgsn ' +  
    ' and      Errorprp.PropSN = 6 '+  
      ' AND      Errorprp.Value= ErrTbl.SN ),' + '''' + '''' + '),' + */
  ' frm.Name,' + 
 ' msg.fromname'  +

' from  ' + @Prefix + 'dbo.tblmessages Msg, ' + 
 	 + @Prefix + 'dbo.tblForms frm, ' + 
	 + @Prefix + 'dbo.tblMsgProperties  prp' +

' where ' + 
' MSG.DTSent >= DateAdd(hour,20,(Cast(Floor(Cast(getdate() as float))as smalldatetime))-1) ' + 
 ' AND ' + 
 ' prp.Propsn = 2 AND frm.sn = prp.value and msg.SN = prp.MsgSn  ' + 
  ' AND [FromType]=4  ' + 
  ' AND (frm.FormID = ' + '''' + @HoursOfServiceFormID + '''' + ')' + 
  ' AND msg.folder = 373 ' +
  --And msg.fromname = TractorProfile.trc_number
  'order by FormID, version, dtsent '

insert into #TractorTemp
Exec (@SQLDyn)

Insert into DriverAwareSuite_Mac17
select  distinct trc_driver,
	case when DTSent is Null Then
	'No'
 	Else
	'Yes'
 	End as Mac17

--select distinct trc_driver,Mac17
From TractorProfile Left Join #TractorTemp On fromname = TractorProfile.trc_number
Where trc_driver <> 'UNKNOWN'
order by trc_driver asc








GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetMAC17] TO [public]
GO
