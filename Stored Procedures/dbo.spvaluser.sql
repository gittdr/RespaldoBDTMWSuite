SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[spvaluser]
(@user varchar(50))
as
select  tu.usr_userid, tu.usr_name ,tu.usr_mail,tu.usr_password from  tlbUserAccess tu inner join ttsusers ttu on tu.usr_userid= ttu.usr_userid 
where  tu.usr_mail =@user and  tu.usr_access = 'Y'
GO
