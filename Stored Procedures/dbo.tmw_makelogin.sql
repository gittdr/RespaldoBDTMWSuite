SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[tmw_makelogin] 					(@user		char(20),
								@userpw		varchar(20),
								@defaultdb	varchar(20),
								@applist	varchar(255),
								@makeadmin	char(1))

AS
/**
 * 
 * NAME: 
 * tmw_makelogin
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure create a tmw login
 *
 * RETURNS:
 * N/A 
 *
 * RESULT SETS: 
 * None
 *
 * PARAMETERS:
 * 001 - @user, char(20), input;
 *       This parameter indicates the tmw user name.
 * 002 - @userpw, varchar(20), input;
 *       This parameter indicates the tmw user's password 
 * 003 - @defaultdb,	varchar(20), input;
 *       This parameter indicates deafult database of the tmw user. 
 * 004 - @applist, varchar(255), input;
 *       This parameter indicates the applications the user will have access to. It's comma delimited.
 * 005 - @makeadmin,	char(1), input;
 *       This parameter indicates whether this user has admin permission. 'Y' or 'N'
 * REFERENCES: 
 * 
 * REVISION HISTORY:
 * 11/10/2006.01 ? PTS35114 - JGUO ? Use "create user" in sql 2005 so that the user is created with default schema 'dbo'
 * 07/22/2008.01 - PTS48366 - JLB  - allow simple logins for SQL 2008
 * 01/21/2010    - PTS50611 - MDH  - Change script to check for SQL Server 2000 instead of 2005 and 2008
 * 08/05/2010	 - PTS53524 - vjh  - explicitly set the admin column to N on the insert
 * 08/05/2010	 - PTS58873 - JD  -  Remove the hardcode applist, allow any string of apps to be created so we can use this for .net as well.
 * 11/02/2011    - PTS59919 - mdh -- Add grant view server state
 **/

BEGIN
declare	@version varchar(2048), 
		@sqlcommand	nvarchar(2048)

select 	@version = @@version
select @applist = RTRIM(LTRIM(@applist))

if LEFT(@applist,1) <> ',' 
	select @applist = ','+@applist

if RIGHT(@applist,1) <> ','
		select @applist = @applist + ','
		

If charindex('SQL Server  2000', @version) > 0 
	SELECT @sqlcommand = N'sp_addlogin ' + ltrim(rtrim(@user)) + ', ' + @userpw + ', ' + @defaultdb
ELSE
	SELECT @sqlcommand = N'CREATE LOGIN ' + ltrim(rtrim(@user)) + ' WITH PASSWORD = ''' + ltrim(rtrim(@userpw)) + ''', DEFAULT_DATABASE = ' + @defaultdb + ', CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF '

-- Now add the login to the Server
If not exists (select * from master..syslogins where [name]= @user)
exec sp_executesql @sqlcommand

-- Now add the user to the database
--PTS35114 use create user for sql2005 so that the user is created with default schema dbo
If charindex('SQL Server  2000', @version) > 0
	SELECT @sqlcommand = N'sp_adduser ' + ltrim(rtrim(@user))
ELSE
	SELECT @sqlcommand = N'CREATE USER ' + ltrim(rtrim(@user)) + ' FOR LOGIN ' + ltrim(rtrim(@user))
If not exists (select * from sysusers where [name] = @user) 
exec sp_executesql @sqlcommand

/* 11/01/2011 MDH PTS 59919: Added code to allow view server state */
If charindex('SQL Server  2000', @version) = 0
BEGIN
	SELECT @sqlcommand = N'use master; grant view server state to ' + ltrim(rtrim(@user)) + '; use ' + db_name() + ';'
	exec sp_executesql @sqlcommand
END

-- Set up for TMWSuite access rights:
--vjh 
--insert into ttsusers (usr_fname, usr_userid, usr_password, usr_type1)
--values( @user, @user, '','UNK') 
if not exists (select * from ttsusers where usr_userid = @user)
insert into ttsusers (usr_fname, usr_userid, usr_password, usr_type1, usr_sysadmin)
values( @user, @user, '','UNK', 'N') 
	  
-- JD commented out the hardcoded list and replaced with code below the commented block

--/*      INSERT INITIAL MAPPINGS */
--If charindex(',ADM,', @applist) > 0
--	insert into ttsmappings (userid, moduleid, programid)
--	values( @user,'ADM', '')

--If charindex(',DIS,', @applist) > 0
--insert into ttsmappings (userid, moduleid, programid)
--values( @user,'DIS','')

--If charindex(',DEV,', @applist) > 0
--insert into ttsmappings (userid, moduleid, programid)
--values( @user,'DEV', '')

--If charindex(',FIL,', @applist) > 0
--insert into ttsmappings (userid, moduleid, programid)
--values( @user,'FIL','')

--If charindex(',INV,', @applist) > 0
--insert into ttsmappings (userid, moduleid, programid)
--values( @user,'INV', '')

--If charindex(',SET,', @applist) > 0
--insert into ttsmappings (userid, moduleid, programid)
--values( @user,'SET', '')

--If charindex(',XFC,', @applist) > 0
--insert into ttsmappings (userid, moduleid, programid)
--values( @user,'XFC', '')

--If charindex(',ORD,', @applist) > 0
--insert into ttsmappings (userid, moduleid, programid)
--values( @user,'ORD', '')

--If charindex(',TAR,', @applist) > 0
--insert into ttsmappings (userid, moduleid, programid)
--values( @user,'TAR', '')

--If charindex(',FTX,', @applist) > 0
--insert into ttsmappings (userid, moduleid, programid)
--values( @user,'FTX', '')

--If charindex(',BRP,', @applist) > 0
--insert into ttsmappings (userid, moduleid, programid)
--values( @user,'BRP', '')

--If charindex(',PSA,', @applist) > 0
--insert into ttsmappings (userid, moduleid, programid)
--values( @user,'PSA', '')


-- Dynamically parse the @applist.
Declare @startPos  int 
Declare @endPos int
Declare @module varchar(3)
select @startPos = 0
select @startPos = CHARINDEX(',',@applist)
WHILE @startPos > 0
BEGIN
	select @startPos = @startPos + 1
	select @endPos = CHARINDEX(',',@applist,@startpos )
	  
	  IF @endPos > 0 
	  BEGIN
		select @module = SUBSTRING(@applist,@startPos,@endPos  - @startPos )
--		select @module,DATALENGTH(@module)
		If not exists (select * from ttsmappings where userid =@user and moduleid = @module) 
		insert into ttsmappings (userid, moduleid, programid)
		values( @user,@module, '')
		
		select  @startPos  = @endPos					
	  END
	  ELSE
	  BEGIN
	   BREAK
	  END

	If @startPos > DATALENGTH (@applist) 
		BREAK	 
	  
END 


-- The sql below gives this ID TMWSuite Administration Authority.
-- If you do not want this ID to have that authority, comment-out
-- these 3 lines by placing '--' at the beginning of each line.
If @makeadmin = 'Y'
	update ttsusers set usr_sysadmin = 'Y'
	where usr_userid= @user

--The following was added on 1/27/04
/* PTS 16667 - DJM - Add columns to hold date and time formats to allow users to 
	override the standard Windows date/time formatting				*/

IF NOT EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
               WHERE  a.name = 'usr_dateformat' AND
                      a.id = b.id AND
                      b.name = 'ttsusers')
	    ALTER TABLE dbo.ttsusers
    	ADD usr_dateformat CHAR(15) NULL

UPDATE ttsusers 
SET usr_dateformat = 'mm/dd/yy'
WHERE usr_dateformat IS NULL


IF NOT EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
               WHERE  a.name = 'usr_timeformat' AND
                      a.id = b.id AND
                      b.name = 'ttsusers')
	    ALTER TABLE dbo.ttsusers
    	ADD usr_timeformat CHAR(15) NULL

UPDATE ttsusers 
SET usr_timeformat = 'hh:mm'
WHERE usr_timeformat IS NULL


/* Create the GeneralInfo setting to turn on/off the setting				*/
If Not exists (Select * from generalinfo where gi_name = 'ApplyUserDateTimeFormat')
  Insert into generalinfo (gi_name,gi_datein,gi_string1,gi_description)
  Values ('ApplyUserDateTimeFormat',Getdate(),'N','Apply the Date and/or Time formats specified by user, if any exist.  Values = Y/N (default = N)')


END
GO
GRANT EXECUTE ON  [dbo].[tmw_makelogin] TO [public]
GO
