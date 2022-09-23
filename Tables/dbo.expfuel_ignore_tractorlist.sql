CREATE TABLE [dbo].[expfuel_ignore_tractorlist]
(
[eit_id] [int] NOT NULL IDENTITY(1, 1),
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_updateby] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE TRIGGER [dbo].[iut_expfuel_ignore_tractorlist]
ON [dbo].[expfuel_ignore_tractorlist]  
FOR INSERT,update  
AS  
   
/* PTS 31689 - DJM - Trigger to track changes made to the Exclude Tractor table		*/
--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255),
	@updatecount	int,
	@delcount	int
exec gettmwuser @tmwuser output  


/* PTS 31689 - DJM - Update the fields tracking last update user and datetime		*/
if (@updatecount > 0 and not update(last_updateby) and not update(last_updatedate)) OR
	(@updatecount > 0 and @delcount = 0)

	Update expfuel_ignore_tractorlist
	set last_updateby = @tmwuser,
		last_updatedate = getdate()
	from inserted
	where inserted.eit_id = expfuel_ignore_tractorlist.eit_id
		and (isNull(expfuel_ignore_tractorlist.last_updateby,'') <> @tmwuser
		OR isNull(expfuel_ignore_tractorlist.last_updatedate,'') <> getdate())





GO
ALTER TABLE [dbo].[expfuel_ignore_tractorlist] ADD CONSTRAINT [PK_expfuel_ignore_tractorlist] PRIMARY KEY CLUSTERED ([eit_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[expfuel_ignore_tractorlist] TO [public]
GO
GRANT INSERT ON  [dbo].[expfuel_ignore_tractorlist] TO [public]
GO
GRANT REFERENCES ON  [dbo].[expfuel_ignore_tractorlist] TO [public]
GO
GRANT SELECT ON  [dbo].[expfuel_ignore_tractorlist] TO [public]
GO
GRANT UPDATE ON  [dbo].[expfuel_ignore_tractorlist] TO [public]
GO
