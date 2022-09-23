CREATE TABLE [dbo].[cashcard]
(
[crd_cardnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[crd_accountid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[crd_customerid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[crd_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_status] DEFAULT ('I'),
[crd_usecard] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_usecard] DEFAULT ('N'),
[crd_directdeposit] [int] NOT NULL CONSTRAINT [df_cashcard_crd_directDeposit] DEFAULT (0),
[crd_atmaccess] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_atmaccess] DEFAULT ('N'),
[crd_vruaccess] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_vruaccess] DEFAULT ('0'),
[crd_limitnetworkbycard] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_limitnetworkbycard] DEFAULT ('0'),
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_asgn_type] DEFAULT ('DRV'),
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_asgn_id] DEFAULT ('UNKNOWN'),
[crd_firstname] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_lastname] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_driverlicensenum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_driverlicensestate] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_unitnumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_unitnumber] DEFAULT ('UNKNOWN'),
[crd_driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_trailernumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_tripnumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_fuelpurchaseyn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_fuelpurchaseyn] DEFAULT ('0'),
[crd_purchaselimit] [money] NULL,
[crd_onetimepurchaselimit] [money] NULL,
[crd_diesellimit] [int] NULL,
[crd_reeferlimit] [int] NULL,
[crd_purchrenewdaily] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_purchrenewdaily] DEFAULT ('0'),
[crd_purchrenewmon] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_purchrenewmon] DEFAULT ('0'),
[crd_purchrenewtue] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_purchrenewtue] DEFAULT ('0'),
[crd_purchrenewwed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_purchrenewwed] DEFAULT ('0'),
[crd_purchrenewthu] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_purchrenewthu] DEFAULT ('0'),
[crd_purchrenewfri] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_purchrenewfri] DEFAULT ('0'),
[crd_purchrenewsat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_purchrenewsat] DEFAULT ('0'),
[crd_purchrenewsun] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_purchrenewsun] DEFAULT ('0'),
[crd_purchrenewtrip] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_purchrenewtrip] DEFAULT ('0'),
[crd_expcashflagyn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_expcashflagyn] DEFAULT ('0'),
[crd_cashlimit] [money] NULL,
[crd_onetimecashlimit] [money] NULL,
[crd_cashbalance] [money] NULL,
[crd_cashrenewdaily] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_cashrenewdaily] DEFAULT ('0'),
[crd_cashrenewmon] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_cashrenewmon] DEFAULT ('0'),
[crd_cashrenewtue] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_cashrenewtue] DEFAULT ('0'),
[crd_cashrenewwed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_cashrenewwed] DEFAULT ('0'),
[crd_cashrenewthu] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_cashrenewthu] DEFAULT ('0'),
[crd_cashrenewfri] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_cashrenewfri] DEFAULT ('0'),
[crd_cashrenewsat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_cashrenewsat] DEFAULT ('0'),
[crd_cashrenewsun] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_cashrenewsun] DEFAULT ('0'),
[crd_cashrenewtrip] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_cashrenewtrip] DEFAULT ('0'),
[crd_phoneserviceyn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_phoneserviceyn] DEFAULT ('0'),
[crd_phoneamountlimit] [money] NULL,
[crd_phonerenewdaily] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_phonerenewdaily] DEFAULT ('0'),
[crd_phonerenewsun] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_phonerenewsun] DEFAULT ('0'),
[crd_phonerenewmon] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_phonerenewmon] DEFAULT ('0'),
[crd_phonerenewtue] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_phonerenewtue] DEFAULT ('0'),
[crd_phonerenewwed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_phonerenewwed] DEFAULT ('0'),
[crd_phonerenewthu] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_phonerenewthu] DEFAULT ('0'),
[crd_phonerenewfri] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_phonerenewfri] DEFAULT ('0'),
[crd_phonerenewsat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_phonerenewsat] DEFAULT ('0'),
[crd_phonerenewtrip] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_phonerenewtrip] DEFAULT ('0'),
[crd_oilamountlimit] [money] NULL,
[crd_oillimit] [int] NULL,
[crd_oilrenewdaily] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_oilrenewdaily] DEFAULT ('0'),
[crd_oilrenewsun] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_oilrenewsun] DEFAULT ('0'),
[crd_oilrenewmon] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_oilrenewmon] DEFAULT ('0'),
[crd_oilrenewtue] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_oilrenewtue] DEFAULT ('0'),
[crd_oilrenewwed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_oilrenewwed] DEFAULT ('0'),
[crd_oilrenewthu] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_oilrenewthu] DEFAULT ('0'),
[crd_oilrenewfri] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_oilrenewfri] DEFAULT ('0'),
[crd_oilrenewsat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_oilrenewsat] DEFAULT ('0'),
[crd_oilrenewtrip] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cashcard_crd_oilrenewtrip] DEFAULT ('0'),
[crd_updatestatus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_errormessage] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_purchrenewdaily_old] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_purchrenewtrip_old] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_cashrenewdaily_old] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_cashrenewtrip_old] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_phonerenewdaily_old] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_phonerenewtrip_old] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_oilrenewdaily_old] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_oilrenewtrip_old] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[limitnetwork_expdate] [datetime] NULL,
[crd_createddate] [datetime] NULL CONSTRAINT [DF_cashcard_crd_createddate] DEFAULT (getdate()),
[crd_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_thirdpartytype] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_vendor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_importbatch] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_crdnumbershort] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_pinnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_drivername] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_onetimefuel_off] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_onetimefuel_off] DEFAULT ('0'),
[crd_mpp_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_crd_mpp_status] DEFAULT ('UNK'),
[crd_save_offline] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_cashcard_crd_save_offline] DEFAULT ('0'),
[crd_updatedby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_cashcard_crd_updatedby] DEFAULT (suser_name()),
[crd_updateddate] [datetime] NULL CONSTRAINT [DF_cashcard_crd_updateddate] DEFAULT (getdate()),
[crd_updatedapp] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_cashcard_crd_updatedapp] DEFAULT (left(app_name(),(20))),
[crd_primary_tractor] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_is_parent_card] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__cashcard__crd_is__18901EC6] DEFAULT ('N'),
[crd_parent_cardnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_send_tpr_as_employeenum] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_send_car_as_employeenum] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_Type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_AdvanceFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__cashcard__crd_re__54EFE8B8] DEFAULT ('N'),
[crd_carrier_card] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__cashcard__crd_ca__4CF4C732] DEFAULT ('N')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--/************************************************************************************************ 
-- * REVISION HISTORY:
-- * Date ?     PTS#  AuthorName Revision Description
-- * 4/21/2005	PTS	  JZ	       If the the list of columns are updated, update 
--                               corresponding _old column to 'C'	to market them changed;
-- * 08/04/2015 xxxxx ERB        Exactly 1 or 2 updates instead of maybe 10.  Also support added for multi row updates.
-- **/
CREATE TRIGGER [dbo].[ut_cashcard] ON [dbo].[cashcard]
FOR UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 



--crd_status PTS 52581 SPN
if UPDATE (crd_status)
begin
   update cashcard
      set crd_status = inserted.crd_status
     from inserted
    where cashcard.crd_parent_cardnumber = inserted.crd_cardnumber
end 

/* JLB PTS 42765*/
update A
set 
  crd_updatedby = suser_name()
 ,crd_updateddate = getdate()
 ,crd_updatedapp = left(app_name(),20)
 ,crd_purchrenewdaily_old = CASE WHEN i.crd_purchrenewdaily <> d.crd_purchrenewdaily THEN 'C' ELSE a.crd_purchrenewdaily_old END
 ,crd_purchrenewtrip_old =  CASE WHEN i.crd_purchrenewtrip  <> d.crd_purchrenewtrip  THEN 'C' ELSE a.crd_purchrenewtrip_old  END
 ,crd_cashrenewdaily_old =  CASE WHEN i.crd_cashrenewdaily  <> d.crd_cashrenewdaily  THEN 'C' ELSE a.crd_cashrenewdaily_old  END
 ,crd_cashrenewtrip_old =   CASE WHEN i.crd_cashrenewtrip   <> d.crd_cashrenewtrip   THEN 'C' ELSE a.crd_cashrenewtrip_old   END
 ,crd_phonerenewdaily_old = CASE WHEN i.crd_phonerenewdaily <> d.crd_phonerenewdaily THEN 'C' ELSE a.crd_phonerenewdaily_old END
 ,crd_phonerenewtrip_old =  CASE WHEN i.crd_phonerenewtrip  <> d.crd_phonerenewtrip  THEN 'C' ELSE a.crd_phonerenewtrip_old  END
 ,crd_oilrenewdaily_old =   CASE WHEN i.crd_oilrenewdaily   <> d.crd_oilrenewdaily   THEN 'C' ELSE a.crd_oilrenewdaily_old   END
 ,crd_oilrenewtrip_old =    CASE WHEN i.crd_oilrenewtrip    <> d.crd_oilrenewtrip    THEN 'C' ELSE a.crd_oilrenewtrip_old    END
from cashcard A INNER JOIN 
    inserted i on
                  i.crd_accountid  = a.crd_accountid
              and i.crd_customerid = a.crd_customerid
              and i.crd_cardnumber = a.crd_cardnumber
    INNER JOIN 
    deleted d on
                  d.crd_accountid  = a.crd_accountid
              and d.crd_customerid = a.crd_customerid
              and d.crd_cardnumber = a.crd_cardnumber

/*end 42765*/
GO
ALTER TABLE [dbo].[cashcard] ADD CONSTRAINT [pk_cashcard] PRIMARY KEY CLUSTERED ([crd_cardnumber], [crd_accountid], [crd_customerid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cashcard] ADD CONSTRAINT [fk_cashcardtocdacctcode] FOREIGN KEY ([crd_accountid]) REFERENCES [dbo].[cdacctcode] ([cac_id])
GO
ALTER TABLE [dbo].[cashcard] ADD CONSTRAINT [fk_cashcardtocdcustcode] FOREIGN KEY ([crd_accountid], [crd_customerid]) REFERENCES [dbo].[cdcustcode] ([cac_id], [ccc_id])
GO
GRANT DELETE ON  [dbo].[cashcard] TO [public]
GO
GRANT INSERT ON  [dbo].[cashcard] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cashcard] TO [public]
GO
GRANT SELECT ON  [dbo].[cashcard] TO [public]
GO
GRANT UPDATE ON  [dbo].[cashcard] TO [public]
GO
