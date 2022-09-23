CREATE TABLE [dbo].[carrierbids]
(
[cb_id] [int] NOT NULL IDENTITY(1, 1),
[ca_id] [int] NULL,
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[carrierlanecommitmentid] [int] NULL,
[car_rating] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_loads_offered] [int] NULL,
[car_loads_responded_to] [int] NULL,
[car_loads_not_responded_to] [int] NULL,
[car_loads_awarded] [int] NULL,
[car_loads_on_time] [int] NULL,
[clc_car_rating] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clc_loads_offered] [int] NULL,
[clc_loads_responded_to] [int] NULL,
[clc_loads_not_responded_to] [int] NULL,
[clc_loads_awarded] [int] NULL,
[clc_loads_on_time] [int] NULL,
[cb_lanename] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_specificity] [int] NULL,
[cb_sent_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_sent_date] [datetime] NULL,
[cb_sent_time_period] [int] NULL,
[cb_sent_expires] [datetime] NULL,
[cb_sent_message] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_sent_email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_sent_email_template] [int] NULL,
[cb_sent_sequence] [int] NULL,
[cb_sent_by_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_sent_by_application] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_reply_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_reply_date] [datetime] NULL,
[cb_reply_expires] [datetime] NULL,
[cb_reply_amount] [money] NULL,
[cb_reply_message] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_award_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_award_datetime] [datetime] NULL,
[cb_award_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_award_application] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_duplicate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_move_derive_data_updated] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_load_requirement] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_fax] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_contact] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_driver_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_driver_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_truck_mcnum] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_trailernumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_reply_reason_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_reply_linehaul] [money] NULL,
[cb_reply_fuelamount] [money] NULL,
[cb_reply_otheramount] [money] NULL,
[ord_booked_revtype1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_booked_revtype1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deadhead_flag] [int] NULL,
[deadhead_origin_city] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deadhead_stop_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deadhead_distance] [decimal] (10, 1) NULL,
[deadhead_dispatch_datetime] [datetime] NULL,
[cb_email_confirmation_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_fax_confirmation_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_print_confirmation_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_dispatch_note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_cancel_message_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_award_message_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_deny_message_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_reply_counter_amount] [money] NULL,
[cb_reply_counter_date] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE trigger [dbo].[it_carrrierbids] on [dbo].[carrierbids] for insert
as

/* Revision History:
	6/9/2009	Greg Kanzinger		cgk	PTS 47805
*/

	--PTS 47805 CGK 6/9/2009
	IF update (cb_reply_linehaul) OR Update (cb_reply_fuelamount) OR Update (cb_reply_otheramount) Begin
		update carrierbids set carrierbids.cb_reply_amount = IsNull (i.cb_reply_linehaul, 0) + IsNull (i.cb_reply_fuelamount, 0) + IsNull (i.cb_reply_otheramount, 0)
		from carrierbids cb, inserted i
		where cb.cb_id =  i.cb_id
	End
        
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE trigger [dbo].[ut_carrrierbids] on [dbo].[carrierbids] for update
as
-- Provides ut_carrrierbidshistory.sql
-- Requires none
/* Revision History:
	11/20/2008	Greg Kanzinger		cgk	PTS 43194
*/

Set NoCount On --PTS 48672
	--PTS 47805 CGK 6/9/2009
	IF update (cb_reply_linehaul) OR Update (cb_reply_fuelamount) OR Update (cb_reply_otheramount) Begin
		update carrierbids set carrierbids.cb_reply_amount = IsNull (i.cb_reply_linehaul, 0) + IsNull (i.cb_reply_fuelamount, 0) + IsNull (i.cb_reply_otheramount, 0)
		from carrierbids cb, inserted i
		where cb.cb_id =  i.cb_id
	End
        
--If Update(cb_reply_status) OR Update (cb_reply_date) OR Update (cb_reply_expires) OR Update (cb_reply_amount) OR Update (cb_reply_message) OR Update (cb_load_requirement)
--OR Update (cb_phone) OR Update (cb_fax) OR Update (cb_contact) OR Update (cb_driver_name) OR Update (cb_driver_phone) OR Update (cb_truck_mcnum) OR Update (cb_trailernumber)
--BEGIN
	insert into carrierbidshistory (cb_id, ca_id, car_id, cb_reply_status, cb_reply_date, cb_reply_expires, cb_reply_amount, cb_reply_message, cb_load_requirement,
					cb_phone, cb_fax, cb_contact, cb_driver_name, cb_driver_phone, cb_truck_mcnum, cb_trailernumber, created_date, created_user,
					cb_reply_otheramount, cb_reply_fuelamount, cb_reply_linehaul)
	select d.cb_id, d.ca_id, d.car_id, d.cb_reply_status, d.cb_reply_date, d.cb_reply_expires, d.cb_reply_amount, d.cb_reply_message, d.cb_load_requirement,
	       d.cb_phone, d.cb_fax, d.cb_contact, d.cb_driver_name, d.cb_driver_phone, d.cb_truck_mcnum, d.cb_trailernumber, d.created_date, d.created_user,
	       d.cb_reply_otheramount, d.cb_reply_fuelamount, d.cb_reply_linehaul
	from deleted d left join inserted i on d.cb_id = i.cb_id
	where IsNull (d.cb_reply_status, '') <> IsNull (i.cb_reply_status, '')
	OR  IsNull (d.cb_reply_date, getdate ()) <> IsNull (i.cb_reply_date, getdate ())
 	OR  IsNull (d.cb_reply_expires, getdate ()) <> IsNull (i.cb_reply_expires, getdate ())
 	--OR  IsNull (d.cb_reply_amount, 0) <> IsNull (i.cb_reply_amount, 0)  /*PTS 48672 CGK 8/18/2009*/
 	OR  IsNull (d.cb_reply_message, '') <> IsNull (i.cb_reply_message, '')
 	OR  IsNull (d.cb_phone, '') <> IsNull (i.cb_phone, '')
 	OR  IsNull (d.cb_fax, '') <> IsNull (i.cb_fax, '')
 	OR  IsNull (d.cb_contact, '') <> IsNull (i.cb_contact, '')
 	OR  IsNull (d.cb_driver_name, '') <> IsNull (i.cb_driver_name, '')
 	OR  IsNull (d.cb_driver_phone, '') <> IsNull (i.cb_driver_phone, '')
 	OR  IsNull (d.cb_truck_mcnum, '') <> IsNull (i.cb_truck_mcnum, '')
 	OR  IsNull (d.cb_trailernumber, '') <> IsNull (i.cb_trailernumber, '')
	OR  IsNull (d.cb_reply_otheramount, 0) <> IsNull (i.cb_reply_otheramount, 0)
	OR  IsNull (d.cb_reply_fuelamount, 0) <> IsNull (i.cb_reply_fuelamount, 0)
	OR  IsNull (d.cb_reply_linehaul, 0) <> IsNull (i.cb_reply_linehaul, 0)
	
		
--END


GO
ALTER TABLE [dbo].[carrierbids] ADD CONSTRAINT [pk_carrierbids_cb_id] PRIMARY KEY CLUSTERED ([cb_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierbids_ca_id] ON [dbo].[carrierbids] ([ca_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierbids_car_id] ON [dbo].[carrierbids] ([car_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierbids_carrierlanecommitmentid] ON [dbo].[carrierbids] ([carrierlanecommitmentid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierbids_cb_award_status] ON [dbo].[carrierbids] ([cb_award_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierbids_cb_reply_status] ON [dbo].[carrierbids] ([cb_reply_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierbids_cb_sent_status] ON [dbo].[carrierbids] ([cb_sent_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierbids_modified_date] ON [dbo].[carrierbids] ([modified_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierbids] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierbids] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierbids] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierbids] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierbids] TO [public]
GO
