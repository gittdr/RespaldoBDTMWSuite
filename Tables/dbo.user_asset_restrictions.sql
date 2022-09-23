CREATE TABLE [dbo].[user_asset_restrictions]
(
[usr_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[uar_asgntype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[uar_asgnid] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[uar_groupflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uar_description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL,
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_user_asset_restrictions]
ON [dbo].[user_asset_restrictions]
FOR INSERT, UPDATE 
AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

Declare @groupcount	int,
	@usercount	int,
	@updatecount	int,
	@delcount	int

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

select @updatecount = count(*) from inserted
select @delcount = count(*) from deleted

if (@updatecount > 0 and not update(last_updateby) and not update(last_updatedate)) OR
	(@updatecount > 0 and @delcount = 0)

	Update user_asset_restrictions
	set last_updateby = @tmwuser,
		last_updatedate = getdate()
	from inserted
	where inserted.usr_userid = user_asset_restrictions.usr_userid
		and inserted.uar_asgntype = user_asset_restrictions.uar_asgntype
		and inserted.uar_asgnid = user_asset_restrictions.uar_asgnid
		and (isnull(user_asset_restrictions.last_updateby,'') <> @tmwuser
		OR isNull(user_asset_restrictions.last_updatedate,'19500101') <> getdate())
	

-- Update the flag indicating that the record is for a User Group
update user_asset_restrictions
set uar_groupflag = 'Y'
from ttsgroups, inserted
where user_asset_restrictions.usr_userid = inserted.usr_userid
	and user_asset_restrictions.usr_userid = ttsgroups.grp_id

-- Update the flag indicating that the record is for a User
update user_asset_restrictions
set uar_groupflag = 'N'
from ttsusers, inserted
where user_asset_restrictions.usr_userid = inserted.usr_userid
	and user_asset_restrictions.usr_userid = ttsusers.usr_userid

GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_uar_restrict] ON [dbo].[user_asset_restrictions] ([usr_userid], [uar_asgntype], [uar_asgnid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[user_asset_restrictions] TO [public]
GO
GRANT INSERT ON  [dbo].[user_asset_restrictions] TO [public]
GO
GRANT REFERENCES ON  [dbo].[user_asset_restrictions] TO [public]
GO
GRANT SELECT ON  [dbo].[user_asset_restrictions] TO [public]
GO
GRANT UPDATE ON  [dbo].[user_asset_restrictions] TO [public]
GO
