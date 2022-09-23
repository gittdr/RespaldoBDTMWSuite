CREATE TABLE [dbo].[standingdeductiontblratedtl]
(
[sdh_number] [int] NOT NULL,
[sdd_number] [int] NOT NULL IDENTITY(1, 1),
[sdd_qty] [money] NOT NULL,
[sdd_rate] [money] NOT NULL,
[sdd_createdby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdd_createddate] [datetime] NULL,
[sdd_updatedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdd_updateddate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itut_standingdeductiontblratedtl] ON [dbo].[standingdeductiontblratedtl] 
FOR INSERT, UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
declare @ll_update int,@ll_sdh_number int , @ll_sdd_number int
--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

select @ll_update = count(*) from deleted
select @ll_sdh_number = sdh_number ,@ll_sdd_number = sdd_number from inserted
IF @ll_update = 0 -- insert
    update standingdeductiontblratedtl set sdd_createdby = @tmwuser , sdd_createddate = getdate(),
    sdd_updatedby = @tmwuser ,sdd_updateddate = getdate() where sdh_number = @ll_sdh_number and sdd_number = @ll_sdd_number
Else -- update
   update standingdeductiontblratedtl set 
    sdd_updatedby = @tmwuser ,sdd_updateddate = getdate() where sdh_number = @ll_sdh_number  and sdd_number = @ll_sdd_number


GO
ALTER TABLE [dbo].[standingdeductiontblratedtl] ADD CONSTRAINT [PK_tariffstlcollectdetail] PRIMARY KEY CLUSTERED ([sdh_number], [sdd_number]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[standingdeductiontblratedtl] ADD CONSTRAINT [FK_tariffstlcollectdetail_tariffstlcollectheader] FOREIGN KEY ([sdh_number]) REFERENCES [dbo].[standingdeductiontblratehdr] ([sdh_number])
GO
GRANT DELETE ON  [dbo].[standingdeductiontblratedtl] TO [public]
GO
GRANT INSERT ON  [dbo].[standingdeductiontblratedtl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[standingdeductiontblratedtl] TO [public]
GO
GRANT SELECT ON  [dbo].[standingdeductiontblratedtl] TO [public]
GO
GRANT UPDATE ON  [dbo].[standingdeductiontblratedtl] TO [public]
GO
