CREATE TABLE [dbo].[cdexpresscash]
(
[cec_accountid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cec_customerid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cec_cardnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cec_amount] [money] NOT NULL,
[cec_pluslessfee] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cec_expresspaycash] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cec_tripnumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cec_misc] [char] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cec_addsubtract] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cec_origination] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cec_issuedate] [datetime] NOT NULL,
[cec_issuedby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cec_updatestatus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cec_errormessage] [char] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cec_loadcashtype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cec_cdnrefnum] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cec_asgntype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cec_asgnid] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cec_responsedate] [datetime] NULL,
[cec_charge] [money] NULL,
[cec_comment] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_number] [int] NULL,
[cec_trackingnum] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[it_cdexpresscash] ON [dbo].[cdexpresscash]
FOR INSERT  as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

UPDATE cdexpresscash 
   SET pyd_number = (SELECT pyd_number 
                       FROM paydetail 
                      WHERE pyd_refnumtype = 'LDMNY' AND 
                            pyd_refnum = cdexpresscash.cec_cdnrefnum)
  FROM inserted 
 WHERE inserted.pyd_number IS NULL
GO
CREATE NONCLUSTERED INDEX [dk_refnumber] ON [dbo].[cdexpresscash] ([cec_cdnrefnum]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdexpresscash] ADD CONSTRAINT [fk_cdexpresscashtocashcard] FOREIGN KEY ([cec_cardnumber], [cec_accountid], [cec_customerid]) REFERENCES [dbo].[cashcard] ([crd_cardnumber], [crd_accountid], [crd_customerid])
GO
ALTER TABLE [dbo].[cdexpresscash] ADD CONSTRAINT [fk_cdexpresscashtocdacctcode] FOREIGN KEY ([cec_accountid]) REFERENCES [dbo].[cdacctcode] ([cac_id])
GO
ALTER TABLE [dbo].[cdexpresscash] ADD CONSTRAINT [fk_cdexpresscashtocdcustcode] FOREIGN KEY ([cec_accountid], [cec_customerid]) REFERENCES [dbo].[cdcustcode] ([cac_id], [ccc_id])
GO
GRANT DELETE ON  [dbo].[cdexpresscash] TO [public]
GO
GRANT INSERT ON  [dbo].[cdexpresscash] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdexpresscash] TO [public]
GO
GRANT SELECT ON  [dbo].[cdexpresscash] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdexpresscash] TO [public]
GO
