CREATE TABLE [dbo].[legheader_brokered]
(
[lgh_number] [int] NOT NULL,
[lgh_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_fax] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_email] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_contact] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_carrier_truck] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_driver_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_driver_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_truck_mcnum] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_trailernumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_booked_revtype1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_lh_brokered_ord_booked_revtype1] DEFAULT ('UNKNOWN'),
[ord_booked_revtype1_amount] [money] NULL,
[ord_booked_revtype1_rate] [decimal] (8, 4) NULL,
[lgh_booked_revtype1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_lh_brokered_lgh_booked_revtype1] DEFAULT ('UNKNOWN'),
[lgh_booked_revtype1_amount] [money] NULL,
[lgh_booked_revtype1_rate] [decimal] (8, 4) NULL,
[ord_booked_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_booked_revtype1_override] [tinyint] NOT NULL CONSTRAINT [df_lh_brokered_ord_booked_revtype1_override] DEFAULT (0),
[lgh_booked_revtype1_override] [tinyint] NOT NULL CONSTRAINT [df_lh_brokered_lgh_booked_revtype1_override] DEFAULT (0),
[lgh_ete_id] [int] NULL,
[lgh_suggested_spend] [money] NULL,
[lgh_confirm_fax] [bit] NULL,
[lgh_confirm_email] [bit] NULL,
[lgh_confirm_print] [bit] NULL,
[lgh_nextaction] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_nextactiondate] [datetime] NULL,
[assign_status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_rule] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rating_option] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[base_charges] [money] NULL,
[acc_charges] [money] NULL,
[total_charges] [money] NULL,
[tar_number] [int] NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[movement_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[probill] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[protected_charge] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_by] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_hdrnumber] [int] NULL,
[accrual_date] [datetime] NULL,
[audit_date] [datetime] NULL,
[audit_by_order] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_external_trailer] [bit] NULL,
[lgh_driver2_name] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_wants_reload] [bit] NULL,
[lgh_reload_city] [int] NOT NULL CONSTRAINT [DF__legheader__lgh_r__4A185A87] DEFAULT ((0)),
[lgh_confirm_cc] [bit] NULL,
[lgh_email_cc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__legheader__INS_T__5A3A174B] DEFAULT (getdate()),
[DW_TIMESTAMP] [timestamp] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_legheader_brokered] ON [dbo].[legheader_brokered]
FOR INSERT, UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE @ete_id int, 
        @org_ete_id int, 
        @lgh	int, 
        @org_truck_count int, 
        @truck_count int, 
        @status varchar(6), 
		@expires datetime 

-- initialize legheader header record counter for loop processing
SELECT @lgh = MIN(lgh_number) 
  FROM inserted 

-- loop through all records in the inserted table
WHILE @lgh > 0 
BEGIN
	-- look for previous external equipment id
	SELECT @org_ete_id = ISNULL(lgh_ete_id, 0) 
      FROM deleted 
     WHERE lgh_number = @lgh
	
	-- find the external equipment record id for assignement
	SELECT @ete_id = ISNULL(lgh_ete_id, 0) 
      FROM inserted 
     WHERE lgh_number = @lgh
	
	-- if the brokered record has a new id from external equipment assigned
	--		then log the transaction and update the external equipment table
	IF @ete_id > 0 And @org_ete_id <> @ete_id
	BEGIN
		-- store current truck count, original truck count, status and expiration date
		SELECT @truck_count = ISNULL(ete_truckcount, 0), 
			   @org_truck_count = ISNULL(ete_original_truckcount, 0), 
               @status = ISNULL(ete_status, 'AVL'), 
               @expires = ISNULL(ete_expirationdate, '19500101') 
		  FROM external_equipment 
		 WHERE ete_id = @ete_id
		
		-- update the external equipment record updating truck count, status and original truck count.
		UPDATE external_equipment 
           SET ete_truckcount = case when @truck_count > 0 then @truck_count - 1 else 0 end, 
               ete_original_truckcount = case when @truck_count > @org_truck_count then @truck_count else @org_truck_count end, 
               ete_status = case when @expires <= GetDate() then 'EXP' 
                                 when @truck_count - 1 < 1 then 'ASGN' 
                                 else ete_status end 
         WHERE ete_id = @ete_id
	END
	
	-- Get next leg header updated 
	SELECT @lgh = MIN(lgh_number) 
	  FROM inserted 
	 WHERE lgh_number > @lgh
END

-- expire any records not expired that should be expired.
UPDATE external_equipment 
   SET ete_status = 'EXP' 
 WHERE ete_expirationdate < GetDate() 
   AND ete_status in ('AVL', 'ASGN') 

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[UTDT_LEGHEADER_BROKERED_AUDIT]
ON [dbo].[legheader_brokered]
FOR UPDATE, DELETE
AS
/**
* 
* NAME:
*	dbo.UTDT_LEGHEADER_BROKERED_AUDIT
*
* TYPE:
*	[Trigger]
*
* DESCRIPTION:
*	Audit updates and deletes on the LEGHEADER_BROKERED table
*
* RETURNS:
*	None.
*
* RESULT SETS: 
*	None.
*
* PARAMETERS:
*	None.
*
* REFERENCES:
*	None.
* 
* REVISION HISTORY:
*	2009/05/22.01	vjh		PTS 47614	Created
*
**/

BEGIN
declare	@ls_audit	varchar(1)

	select	@ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
	  from	generalinfo g1
	  where	g1.gi_name = 'LEGHEADER_BROKERED_AUDIT'

	if @ls_audit = 'Y'
		INSERT INTO LEGHEADER_BROKERED_AUDIT
		SELECT 
				lgh_number, 
				lgh_phone,
				lgh_fax,
				lgh_email,
				lgh_contact,
				lgh_carrier_truck,
				lgh_driver_name,
				lgh_driver_phone,
				lgh_truck_mcnum,
				ord_booked_revtype1,
				ord_booked_revtype1_amount,
				ord_booked_revtype1_rate,
				lgh_booked_revtype1,
				lgh_booked_revtype1_amount,
				lgh_booked_revtype1_rate,
				dbo.gettmwuser_fn(),
				getDate(),
				@@SPID
		FROM DELETED
END

GO
ALTER TABLE [dbo].[legheader_brokered] ADD CONSTRAINT [PK__legheader_broker__12572562] PRIMARY KEY CLUSTERED ([lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [legheader_brokered_INS_TIMESTAMP] ON [dbo].[legheader_brokered] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [lhb_pay_hdrnumber] ON [dbo].[legheader_brokered] ([pay_hdrnumber], [lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[legheader_brokered] TO [public]
GO
GRANT INSERT ON  [dbo].[legheader_brokered] TO [public]
GO
GRANT REFERENCES ON  [dbo].[legheader_brokered] TO [public]
GO
GRANT SELECT ON  [dbo].[legheader_brokered] TO [public]
GO
GRANT UPDATE ON  [dbo].[legheader_brokered] TO [public]
GO
