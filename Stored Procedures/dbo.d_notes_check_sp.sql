SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_notes_check_sp] (	@mode		int,
					@mov_number	int,
					@ord_hdrnumber 	int,
					@ivh_invoicenumber varchar(12),
					@evt_driver1	varchar(8),
					@evt_driver2	varchar(8),
					@evt_tractor	varchar(8),
					@evt_trailer1	varchar(13),
					@evt_trailer2	varchar(13),
					@evt_carrier	varchar(8),
					@origin_cmpid	varchar(8),
					@dest_cmpid	varchar(8),
					@billto_cmpid	varchar(8),
					@pyh_number	int,
					@cmd_code       varchar(8),
					@third_party    varchar(8),
				  	@ord_notes   	int 		out)
AS
/*CGK PTS 22349 7/5/2005 Added Code for Custom Notes Icon.*/
/*CGK PTS 29632 9/1/2005 Modified Return Code to put emphasis on Alert Notes*/
/* CGK PTS 29457 CGK 9/14/2005 Modified Return Code to take into acount multiple results for an Alert Note and a Note Note.
				To into Account the Processing Order as well when determining what value to return. */
/*------------------*/
/* REVISION HISTORY:*/
-- Date ? 		PTS# - 	AuthorName ? Revision Description
-- 10/08/2007	37655	SLM			 With the new INI, ViewCompanyNotesInFMOnly=Y, notes flagged "COPRO" in the NoteRe field are invisible in other apps.
--									 If the note is invisible, make the note icon grey.
 -- 08/01/08 PTS 43959 SGB change commodity lookup to use freightdetail and not legheader table
-- 5/6/09 PTS 46487 when the not_type field is null on all company notes, a company note is not poping up in Order entry
--    where INI PopNotesOrd=Y
-- 09/28/2011 PTS 58500 SPN
DECLARE	@urgent_code		varchar(1),
	@note_count		int,
	@ord_number             varchar(12),
	@grace	int,
	@customnotesicon	varchar (1), /*PTS 22349 CGK 7/5/2005*/
	@bitmap_id int, /*PTS 22349 CGK 7/5/2005*/
	@processing_order int, @found_processing_order int /* PTS 29457 CGK 9/14/2005*/
      , @gi_COMPANY_ALERT_IN_SETTLEMENT varchar(1)	/* PTS 58500 SPN */

select @grace =isnull(gi_integer1,0)
from generalinfo
where gi_name = 'showexpirednotesgrace'

SELECT @note_count = 0
SELECT @ord_notes = 0
SELECT @urgent_code = ''
SELECT @ivh_invoicenumber = IsNull(@ivh_invoicenumber, '')
SELECT @evt_driver1 = IsNull(@evt_driver1, '')
SELECT @evt_driver2 = IsNull(@evt_driver2, '')
SELECT @evt_tractor = IsNull(@evt_tractor, '')
SELECT @evt_trailer1 = IsNull(@evt_trailer1, '')
SELECT @evt_trailer2 = IsNull(@evt_trailer2, '')
SELECT @evt_carrier = IsNull(@evt_carrier, '')
SELECT @origin_cmpid = IsNull(@origin_cmpid, '')
SELECT @dest_cmpid = IsNull(@dest_cmpid, '')
SELECT @pyh_number = IsNull(@pyh_number, 0)
select @cmd_code = IsNull(@cmd_code, '')
select @third_party = IsNull(@third_party, '')

-- BEGIN PTS 58500 SPN
SELECT @gi_COMPANY_ALERT_IN_SETTLEMENT = gi_string1
  FROM generalinfo
 WHERE gi_name = 'COMPANY_ALERT_IN_SETTLEMENT'
SELECT @gi_COMPANY_ALERT_IN_SETTLEMENT = IsNull(@gi_COMPANY_ALERT_IN_SETTLEMENT, 'N')
-- END PTS 58500 SPN

/*PTS 22349 CGK 7/5/2005*/
select @customnotesicon =gi_string1
from generalinfo
where gi_name = 'CustomNotesIcon'

select @customnotesicon = IsNull (@customnotesicon, 'N')

select @bitmap_id = -1000
select @found_processing_order = 100001 /* PTS 29457 CGK 9/14/2005*/
/*END PTS 22349 CGK 7/5/2005*/

 /*PTS 22349 CGK 7/5/2005*/
IF @customnotesicon = 'Y'
BEGIN

  BEGIN

  /*PTS 22349 CGK 7/5/2005*/
   IF @customnotesicon = 'Y'
   BEGIN
	SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
	   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
	   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
		and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
		and	nrm.nrm_mode_id = @mode
		and	nr.nir_id = nrm.nrm_nir_id
		and 	nr.nir_id = nrlt.nrl_nir_id
		and 	n.ntb_table = 'movement'
		and	n.nre_tablekey = CONVERT(CHAR(12), @mov_number)
		and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
	order by nr.nir_processing_order

	select @bitmap_id = IsNull (@bitmap_id, -1000)
	select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
	/*PTS 29632 CGK 9/1/2005*/
	IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
		IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
			select @note_count = @bitmap_id
			select @found_processing_order = @processing_order
		End
	End
	/*END PTS 29632 CGK 9/1/2005*/
   END
   /*END PTS 22349 CGK 7/5/2005*/
  END

  BEGIN

   IF @ord_hdrnumber > 0
	BEGIN

	/*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and 	n.ntb_table = 'orderheader' AND
				(n.nre_tablekey = CONVERT(char(12),@ord_hdrnumber) or
				 n.nre_tablekey = @ord_number)
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order

		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	    END
	END
  END

/*PTS 24849 CGK 10/6/2004*/
   BEGIN

   IF @ord_hdrnumber > 0
     BEGIN
	/*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt, Task
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			AND     n.ntb_table = 'TASK'
		  	AND    	n.nre_tablekey= Convert (char (12), TASK.TASK_ID)
	  	  	AND 	Convert (char (12), TASK.TASK_LINK_ENTITY_SYS_VALUE) = @ord_number
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order

		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/
	END
  END

  BEGIN


   /* Do not check for invoice notes under mode 3 (settlements) */
   If (@ivh_invoicenumber = '' or @ivh_invoicenumber is null) AND @mode <> 3

	BEGIN

	/*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'invoiceheader'
		  	AND    	n.nre_tablekey IN (	SELECT ivh_invoicenumber
						FROM   invoiceheader
						WHERE mov_number = @mov_number)
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order

		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
	/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/

	END
   ELSE
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'invoiceheader'
		  	AND  	n.nre_tablekey = @ivh_invoicenumber
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/

	END

  END


  BEGIN

   SELECT @urgent_code = ''

   /* Check for payheader notes under mode 3 (settlements) */
   If @pyh_number > 0 AND @mode = 3

	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'payheader'
		  	AND  	n.nre_tablekey = Convert(varchar(18), @pyh_number)
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/

	END
  END


  BEGIN

   -- BEGIN PTS 58500 SPN
   /* If mode = 1, 4, 5, or 6 (OE, tripfolder, asset assingment, or geofuel), check all existing companies */
   --IF @mode = 1 OR @mode = 4 OR @mode = 5 OR @mode = 6
   IF @mode = 1 OR @mode = 4 OR @mode = 5 OR @mode = 6 OR (@gi_COMPANY_ALERT_IN_SETTLEMENT = 'Y' AND @mode = 3)
   -- END PTS 58500 SPN

	BEGIN

 	   BEGIN

		  /*PTS 22349 CGK 7/5/2005*/
		   IF @customnotesicon = 'Y'
		   BEGIN
			SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
			   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
			   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
				and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
				and	nrm.nrm_mode_id = @mode
				and	nr.nir_id = nrm.nrm_nir_id
				and 	nr.nir_id = nrlt.nrl_nir_id
				and   	n.ntb_table = 'company'
                AND (isnull(n.not_type,'') = '' or
                 n.not_type <> --SLM PTS 37655
					IsNull((select gi_string2 from generalinfo
						where gi_name = 'PreventCOPRONotetypeDisplay' and
						Upper(gi_string1) = 'Y'),' ') )
			  	AND  	n.nre_tablekey IN (SELECT cmp_id
						   FROM stops
						   WHERE mov_number = @mov_number
						   --BEGIN PTS 58500 SPN
						   UNION ALL
						   SELECT ord_billto
						     FROM orderheader
						    WHERE mov_number = @mov_number
						      AND @gi_COMPANY_ALERT_IN_SETTLEMENT = 'Y' AND @mode = 3
						   UNION ALL
						   SELECT ord_company
						     FROM orderheader
						    WHERE mov_number = @mov_number
						      AND @gi_COMPANY_ALERT_IN_SETTLEMENT = 'Y' AND @mode = 3
						   --END PTS 58500 SPN
						   )
				and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
			order by nr.nir_processing_order
			select @bitmap_id = IsNull (@bitmap_id, -1000)
			select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
			/*PTS 29632 CGK 9/1/2005*/
			/*PTS 29632 CGK 9/1/2005*/
			IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
				IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
					select @note_count = @bitmap_id
					select @found_processing_order = @processing_order
				End
			END
			/*END PTS 29632 CGK 9/1/2005*/
		   END
		/*END PTS 22349 CGK 7/5/2005*/

	   END
	END
  END

  BEGIN

   /* Do not check for company notes under mode 3 (settlements) */
   IF @origin_cmpid = '' and @mode <> 3
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt, orderheader
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and     ord_hdrnumber = @ord_hdrnumber
			and   	n.ntb_table = 'company'
            AND (isnull(n.not_type,'') = '' or
                 n.not_type <> --SLM PTS 37655
					IsNull((select gi_string2 from generalinfo
						where gi_name = 'PreventCOPRONotetypeDisplay' and
						Upper(gi_string1) = 'Y'),' ') )
		  	AND  	n.nre_tablekey = ord_originpoint
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/

	END
   ELSE
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'company'
            AND (isnull(n.not_type,'') = '' or
                 n.not_type <> --SLM PTS 37655
					IsNull((select gi_string2 from generalinfo
						where gi_name = 'PreventCOPRONotetypeDisplay' and
						Upper(gi_string1) = 'Y'),' ') )
		  	AND  	n.nre_tablekey = @origin_cmpid
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/

	END
  END

  BEGIN

      /* Do not check for company notes under mode 3 (settlements) */
   IF @dest_cmpid = '' and @mode <> 3
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt, orderheader
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and  	ord_hdrnumber = @ord_hdrnumber
			and   	n.ntb_table = 'company'
            AND (isnull(n.not_type,'') = '' or
                 n.not_type <> --SLM PTS 37655
					IsNull((select gi_string2 from generalinfo
						where gi_name = 'PreventCOPRONotetypeDisplay' and
						Upper(gi_string1) = 'Y'),' ') )
		  	AND  	n.nre_tablekey = ord_destpoint
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/

	END
   ELSE

	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'company'
            AND (isnull(n.not_type,'') = '' or
                 n.not_type <> --SLM PTS 37655
					IsNull((select gi_string2 from generalinfo
						where gi_name = 'PreventCOPRONotetypeDisplay' and
						Upper(gi_string1) = 'Y'),' ') )
		  	AND  	n.nre_tablekey = @dest_cmpid
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order

		/*PTS 29632 CGK 9/1/2005*/
		/*IF @bitmap_id > -1000
		Begin
			select @note_count = @bitmap_id
			GOTO endprocessing
		End*/

		IF @bitmap_id = -1
		Begin
			select @note_count = @bitmap_id
			GOTO endprocessing
		End

		IF @bitmap_id = 1
		Begin
			select @note_count = @bitmap_id
		End
		Else
		Begin
			If ((@bitmap_id > -1000 and @bitmap_id < -1) OR @bitmap_id = 0) AND @note_count = 0
			Begin
				select @note_count = @bitmap_id
			End
		End
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/

	END
  END

  BEGIN

    /* Only check bill to notes for Ord Entry and Invoicing (Mode 1 and 2) */
   IF (@mode = 1 OR @mode = 2)
      IF @billto_cmpid = ''
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt, orderheader
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and     ord_hdrnumber = @ord_hdrnumber
			and   	n.ntb_table = 'company'
            AND (isnull(n.not_type,'') = '' or
                 n.not_type <> --SLM PTS 37655
					IsNull((select gi_string2 from generalinfo
						where gi_name = 'PreventCOPRONotetypeDisplay' and
						Upper(gi_string1) = 'Y'),' ') )
		  	AND  	n.nre_tablekey = ord_billto
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/

	END
      ELSE

	BEGIN


	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'company'
            AND (isnull(n.not_type,'') = '' or
                 n.not_type <> --SLM PTS 37655
					IsNull((select gi_string2 from generalinfo
						where gi_name = 'PreventCOPRONotetypeDisplay' and
						Upper(gi_string1) = 'Y'),' ') )
		  	AND  	n.nre_tablekey = @billto_cmpid
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/

	END
  END

  /* Do not check asset notes in Invoicing (Mode 2)*/
  --If @mode <> 2 PTS 39002 CGK 9/24/2007.  We can control this using Notes Icon Selection Criteria window.
  BEGIN

   SELECT @urgent_code = ''

   If @evt_driver1 = ''
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'manpowerprofile'
		  	and 	n.nre_tablekey IN (	SELECT	lgh_driver1
				    		 	FROM 	legheader
				     			WHERE	mov_number = @mov_number)
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/

	END

   ELSE
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'manpowerprofile'
		  	and 	n.nre_tablekey = @evt_driver1
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/
	END
  END

  /* Do not check asset notes in Invoicing (Mode 2)*/
  --If @mode <> 2 PTS 39002 CGK 9/24/2007.  We can control this using Notes Icon Selection Criteria window.
  BEGIN

   SELECT @urgent_code = ''

   If @evt_driver2 = ''
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'manpowerprofile'
		 	and 	n.nre_tablekey IN (	SELECT	lgh_driver2
				     			FROM 	legheader
				     			WHERE	mov_number = @mov_number)
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/
	END
   ELSE
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'manpowerprofile'
		 	and 	n.nre_tablekey = @evt_driver2
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/
	END
  END

  /* Do not check asset notes in Invoicing (Mode 2)*/
  --If @mode <> 2 PTS 39002 CGK 9/24/2007.  We can control this using Notes Icon Selection Criteria window.
  BEGIN

   SELECT @urgent_code = ''

   If @evt_tractor = ''
	BEGIN
	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'tractorprofile'
		 	and 	n.nre_tablekey IN (	SELECT	lgh_tractor
				    			FROM 	legheader
						     	WHERE	mov_number = @mov_number)
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/
	END
   ELSE
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'tractorprofile'
		 	and 	n.nre_tablekey = @evt_tractor
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/

	END
  END

  /* Do not check asset notes in Invoicing (Mode 2)*/
  --If @mode <> 2 PTS 39002 CGK 9/24/2007.  We can control this using Notes Icon Selection Criteria window.
  BEGIN

   SELECT @urgent_code = ''
   If @evt_trailer1 = ''
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'trailerprofile'
		 	and 	 n.nre_tablekey IN (	SELECT	lgh_primary_trailer
				     			FROM 	legheader
				     			WHERE	mov_number = @mov_number)
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/
	END
   ELSE
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'trailerprofile'
		 	and 	n.nre_tablekey = @evt_trailer1
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/
	END
  END

  /* Do not check asset notes in Invoicing (Mode 2)*/
  --If @mode <> 2 PTS 39002 CGK 9/24/2007.  We can control this using Notes Icon Selection Criteria window.
  BEGIN

   SELECT @urgent_code = ''

   If @evt_trailer2 = ''
	BEGIN
	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'trailerprofile'
		 	and 	n.nre_tablekey IN (	SELECT	lgh_primary_pup
				     			FROM 	legheader
				     			WHERE	mov_number = @mov_number)
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/
	END
   ELSE
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'trailerprofile'
		 	and 	n.nre_tablekey = @evt_trailer2
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/
	END
  END


  /* Do not check asset notes in Invoicing (Mode 2)*/
  --If @mode <> 2 PTS 39002 CGK 9/24/2007.  We can control this using Notes Icon Selection Criteria window.
  BEGIN

   SELECT @urgent_code = ''
   If @evt_carrier = ''
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'carrier'
		 	and 	n.nre_tablekey IN (	SELECT	lgh_carrier
				     			FROM 	legheader
				     			WHERE	mov_number = @mov_number)
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/
	  END
   ELSE
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'carrier'
		 	and 	n.nre_tablekey = @evt_carrier
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/
	END
  END

 --ILB 15728 03/31/03
 --Only check Third party notes for Ord Entry (Mode 1), Settlements (Mode 3)
   IF (@mode = 1 or @mode = 3)
      IF @third_party = ''
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt, orderheader
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and	ord_hdrnumber = @ord_hdrnumber
			and   	n.ntb_table = 'thirdpartyprofile'
		 	and 	n.nre_tablekey = ord_thirdpartytype1
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/
	END
      ELSE

	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'thirdpartyprofile'
		 	and 	n.nre_tablekey = @third_party
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/
	END
  --ILB 15728 03/31/03

  --If @mode <> 2
  --BEGIN

   SELECT @urgent_code = ''
   If @cmd_code = ''
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'commodity'
		 	and 	n.nre_tablekey IN (	SELECT 	cmd_code
			 				FROM 	legheader
				     			WHERE	mov_number = @mov_number)
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/
	  END
   ELSE
	BEGIN

	  /*PTS 22349 CGK 7/5/2005*/
	   IF @customnotesicon = 'Y'
	   BEGIN
		SELECT	top 1 @bitmap_id = nir_output_bitmap_id, @processing_order = nir_processing_order
		   FROM		notes n, notesiconrules nr, notesiconrulesmodes nrm, notesiconruleslabels nrlt
		   WHERE	IsNull (n.not_urgent, '') = IsNull (nr.nir_not_urgent, '')
			and	IsNull (n.not_type, '') = IsNull (nrlt.nrl_abbr, '') and nrlt.nrl_labeldefinition = 'NoteRe'
			and	nrm.nrm_mode_id = @mode
			and	nr.nir_id = nrm.nrm_nir_id
			and 	nr.nir_id = nrlt.nrl_nir_id
			and   	n.ntb_table = 'commodity'
		 	and 	n.nre_tablekey = @cmd_code
			and	getdate() <= IsNull(DATEADD(day, 4, n.not_expires), getdate())
		order by nr.nir_processing_order
		select @bitmap_id = IsNull (@bitmap_id, -1000)
		select @processing_order = IsNull (@processing_order, 100000) /* PTS 29457 CGK 9/14/2005*/
		/*PTS 29632 CGK 9/1/2005*/
	/*PTS 29632 CGK 9/1/2005*/
		IF @bitmap_id <= 1 OR @bitmap_id > -1000 Begin /* PTS 29457 CGK 9/14/2005*/
			IF @processing_order <= @found_processing_order Begin/* PTS 29457 CGK 9/14/2005*/
				select @note_count = @bitmap_id
				select @found_processing_order = @processing_order
			End
		END
		/*END PTS 29632 CGK 9/1/2005*/
	   END
	/*END PTS 22349 CGK 7/5/2005*/
	END
  --END
END
/*END PTS 22349 CGK 7/5/2009*/

if @mode = 2 select @mode = 1 /*PTS 29632 CGK 9/14/2005 Invoicing Window used to Pass in Mode 1*/
IF @bitmap_id > -1000 GOTO endprocessing

BEGIN


  BEGIN

   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
   FROM		notes n
   WHERE	n.ntb_table = 'movement' AND
		n.nre_tablekey = CONVERT(CHAR(12), @mov_number) AND
		getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

   IF @urgent_code = 'A'
	BEGIN
	   SELECT @note_count = -1
	   GOTO endprocessing
	END
   ELSE
	BEGIN
	   IF @urgent_code = 'N'
		BEGIN
		   SELECT @note_count = 1
		END
	   ELSE IF @note_count = 0 SELECT @note_count = 0
	END

  END

  BEGIN

   SELECT @urgent_code = ''
   IF @ord_hdrnumber > 0
	BEGIN
	   select @ord_number = ord_number
	   from   orderheader
	   where  ord_hdrnumber = @ord_hdrnumber

	   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM		notes n
	   WHERE	n.ntb_table = 'orderheader' AND
			(n.nre_tablekey = CONVERT(char(12),@ord_hdrnumber) or
			 n.nre_tablekey = @ord_number) AND
			getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END
  END

/*PTS 24849 CGK 10/6/2004*/
   BEGIN
   SELECT @urgent_code = ''
   IF @ord_hdrnumber > 0
	BEGIN

	   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM		notes n, TASK
	   WHERE	n.ntb_table = 'TASK'
	   AND    	n.nre_tablekey= Convert (char (12), TASK.TASK_ID)
  	   AND 		Convert (char (12), TASK.TASK_LINK_ENTITY_SYS_VALUE) = @ord_number
	   AND		getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END
  END

  BEGIN

   SELECT @urgent_code = ''

   /* Do not check for invoice notes under mode 3 (settlements) */
   If (@ivh_invoicenumber = '' or @ivh_invoicenumber is null) AND @mode <> 3

	BEGIN

	   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM		notes n
	   WHERE	n.ntb_table = 'invoiceheader' AND
			getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate()) AND
			n.nre_tablekey IN (	SELECT ivh_invoicenumber
						FROM   invoiceheader
						WHERE mov_number = @mov_number)


	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END


	END
   ELSE
	BEGIN
	   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM		notes n
	   WHERE	n.ntb_table = 'invoiceheader' AND
			n.nre_tablekey = @ivh_invoicenumber AND
			@ivh_invoicenumber <> '' AND
			getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END

  END


  BEGIN

   SELECT @urgent_code = ''

   /* Check for payheader notes under mode 3 (settlements) */
   If @pyh_number > 0 AND @mode = 3

	BEGIN

	   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM		notes n
	   WHERE	n.ntb_table = 'payheader' AND
			getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate()) AND
			n.nre_tablekey = Convert(varchar(18), @pyh_number)


	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END


	END
  END


  BEGIN

   -- BEGIN PTS 58500 SPN
   /* If mode = 1, 4, 5, or 6 (OE, tripfolder, asset assingment, or geofuel), check all existing companies */
   --IF @mode = 1 OR @mode = 4 OR @mode = 5 OR @mode = 6
   IF @mode = 1 OR @mode = 4 OR @mode = 5 OR @mode = 6 OR (@gi_COMPANY_ALERT_IN_SETTLEMENT = 'Y' AND @mode = 3)
   -- END PTS 58500 SPN

	BEGIN

	   SELECT @urgent_code = ''

 	   BEGIN
		   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
		   FROM		notes n
		   WHERE	n.ntb_table = 'company'
                 AND (isnull(n.not_type,'') = '' or
                 n.not_type <> --SLM PTS 37655
					IsNull((select gi_string2 from generalinfo
						where gi_name = 'PreventCOPRONotetypeDisplay' and
						Upper(gi_string1) = 'Y'),' ') ) AND
				getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate()) AND
				n.nre_tablekey IN (SELECT cmp_id
						   FROM stops
						   WHERE mov_number = @mov_number
						   --and stp_event <> 'BMT'
                           and stp_type in ('PUP','DRP') -- pts 32443
                           --BEGIN PTS 58500 SPN
                           UNION ALL
                           SELECT ord_billto
                             FROM orderheader
                            WHERE mov_number = @mov_number
                              AND @gi_COMPANY_ALERT_IN_SETTLEMENT = 'Y' AND @mode = 3
                           UNION ALL
                           SELECT ord_company
                             FROM orderheader
                            WHERE mov_number = @mov_number
                              AND @gi_COMPANY_ALERT_IN_SETTLEMENT = 'Y' AND @mode = 3
                           --END PTS 58500 SPN
                           )


		   IF @urgent_code = 'A'
			BEGIN
			   SELECT @note_count = -1
			   GOTO endprocessing

			END
		   ELSE
			BEGIN
			   IF @urgent_code = 'N'
				BEGIN
				   SELECT @note_count = 1
				END
			   ELSE IF @note_count = 0 SELECT @note_count = 0
			END
	   END
	END
  END

  BEGIN

   SELECT @urgent_code = ''

   /* Do not check for company notes under mode 3 (settlements) */
   IF @origin_cmpid = '' and @mode <> 3
	BEGIN
	   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM		notes n, orderheader
	   WHERE	ord_hdrnumber = @ord_hdrnumber AND
			n.ntb_table = 'company'
                AND (isnull(n.not_type,'') = '' or
                 n.not_type <> --SLM PTS 37655
					IsNull((select gi_string2 from generalinfo
						where gi_name = 'PreventCOPRONotetypeDisplay' and
						Upper(gi_string1) = 'Y'),' ') ) AND
			n.nre_tablekey = ord_originpoint AND
			getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())


	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END
   ELSE
	BEGIN

		SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
		FROM	notes n
		WHERE	n.ntb_table = 'company'
                AND (isnull(n.not_type,'') = '' or
                 n.not_type <> --SLM PTS 37655
					IsNull((select gi_string2 from generalinfo
						where gi_name = 'PreventCOPRONotetypeDisplay' and
						Upper(gi_string1) = 'Y'),' ') ) AND
			n.nre_tablekey = @origin_cmpid AND
			getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END

  END

  BEGIN

   SELECT @urgent_code = ''
   /* Do not check for company notes under mode 3 (settlements) */
   IF @dest_cmpid = '' and @mode <> 3
	BEGIN
	   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM		notes n, orderheader
	   WHERE	ord_hdrnumber = @ord_hdrnumber AND
			n.ntb_table = 'company'
            AND (isnull(n.not_type,'') = '' or
                 n.not_type <> --SLM PTS 37655
					IsNull((select gi_string2 from generalinfo
						where gi_name = 'PreventCOPRONotetypeDisplay' and
						Upper(gi_string1) = 'Y'),' ') ) AND
			n.nre_tablekey = ord_destpoint AND
			getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END
   ELSE

	BEGIN

	SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	FROM	notes n
	WHERE	n.ntb_table = 'company'
        AND (isnull(n.not_type,'') = '' or
             n.not_type <> --SLM PTS 37655
					IsNull((select gi_string2 from generalinfo
						where gi_name = 'PreventCOPRONotetypeDisplay' and
						Upper(gi_string1) = 'Y'),' ') ) AND
		n.nre_tablekey = @dest_cmpid AND
		getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END

  END

  BEGIN

   SELECT @urgent_code = ''

   /* Only check bill to notes for Ord Entry and Invoicing (Mode 1 and 2) */
   IF (@mode = 1 OR @mode = 2)
      IF @billto_cmpid = ''
	BEGIN
	   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM		notes n, orderheader
	   WHERE	ord_hdrnumber = @ord_hdrnumber AND
			n.ntb_table = 'company'
            AND (isnull(n.not_type,'') = '' or
            n.not_type <> --SLM PTS 37655
					IsNull((select gi_string2 from generalinfo
						where gi_name = 'PreventCOPRONotetypeDisplay' and
						Upper(gi_string1) = 'Y'),' ') ) AND
			n.nre_tablekey = ord_billto AND
			getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END
      ELSE

	BEGIN

	SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	FROM	notes n
	WHERE	n.ntb_table = 'company'
    AND (isnull(n.not_type,'') = '' or
       n.not_type <> --SLM PTS 37655
					IsNull((select gi_string2 from generalinfo
						where gi_name = 'PreventCOPRONotetypeDisplay' and
						Upper(gi_string1) = 'Y'),' ') ) AND
		n.nre_tablekey = @billto_cmpid   AND
		getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END
  END

  /* Do not check asset notes in Invoicing (Mode 2)*/
  --If @mode <> 2 PTS 39002 CGK 9/24/2007.  We can control this using Notes Icon Selection Criteria window.
  BEGIN

   SELECT @urgent_code = ''

   If @evt_driver1 = ''
	BEGIN
	   SELECT @urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM	  notes n
	   WHERE  n.ntb_table = 'manpowerprofile' AND
		  getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate()) AND
		  n.nre_tablekey IN (SELECT	lgh_driver1
				     FROM 	legheader
				     WHERE	mov_number = @mov_number)

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END

   ELSE
	BEGIN

	   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM		notes n
	   WHERE	n.ntb_table = 'manpowerprofile' AND
			n.nre_tablekey = @evt_driver1 AND
			getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1

			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END

  END

  /* Do not check asset notes in Invoicing (Mode 2)*/
  --If @mode <> 2 PTS 39002 CGK 9/24/2007.  We can control this using Notes Icon Selection Criteria window.
  BEGIN

   SELECT @urgent_code = ''

   If @evt_driver2 = ''
	BEGIN
	   SELECT @urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM	  notes n
	   WHERE  n.ntb_table = 'manpowerprofile' AND
		  getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate()) AND
		  n.nre_tablekey IN (SELECT	lgh_driver2
				     FROM 	legheader
				     WHERE	mov_number = @mov_number)

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END
   ELSE
	BEGIN
	   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM		notes n
	   WHERE	n.ntb_table = 'manpowerprofile' AND
			n.nre_tablekey = @evt_driver2 AND
			getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END

  END

  /* Do not check asset notes in Invoicing (Mode 2)*/
  --If @mode <> 2 PTS 39002 CGK 9/24/2007.  We can control this using Notes Icon Selection Criteria window.
  BEGIN

   SELECT @urgent_code = ''

   If @evt_tractor = ''
	BEGIN
	   SELECT @urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM	  notes n
	   WHERE  n.ntb_table = 'tractorprofile' AND
		  getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate()) AND
		  n.nre_tablekey IN (SELECT	lgh_tractor
				     FROM 	legheader
				     WHERE	mov_number = @mov_number)

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END
   ELSE
	BEGIN
	   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM		notes n
	   WHERE	n.ntb_table = 'tractorprofile' AND
			n.nre_tablekey = @evt_tractor AND
			getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END
  END

  /* Do not check asset notes in Invoicing (Mode 2)*/
  --If @mode <> 2 PTS 39002 CGK 9/24/2007.  We can control this using Notes Icon Selection Criteria window.
  BEGIN

   SELECT @urgent_code = ''
   If @evt_trailer1 = ''
	BEGIN
	   SELECT @urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM	  notes n
	   WHERE  n.ntb_table = 'trailerprofile' AND
		  getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate()) AND
		  n.nre_tablekey IN (SELECT	lgh_primary_trailer

				     FROM 	legheader
				     WHERE	mov_number = @mov_number)

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END
   ELSE
	BEGIN
	   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM		notes n
	   WHERE	n.ntb_table = 'trailerprofile' AND
			n.nre_tablekey = @evt_trailer1 AND
			getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END
  END

  /* Do not check asset notes in Invoicing (Mode 2)*/
  --If @mode <> 2 PTS 39002 CGK 9/24/2007.  We can control this using Notes Icon Selection Criteria window.
  BEGIN

   SELECT @urgent_code = ''

   If @evt_trailer2 = ''
	BEGIN
	   SELECT @urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM	  notes n
	   WHERE  n.ntb_table = 'trailerprofile' AND
		  getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate()) AND
		  n.nre_tablekey IN (SELECT	lgh_primary_pup
				     FROM 	legheader
				     WHERE	mov_number = @mov_number)


	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END

		   ELSE IF @note_count = 0 SELECT @note_count = 0

		END

	END
   ELSE
	BEGIN
	   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM		notes n
	   WHERE	n.ntb_table = 'trailerprofile' AND
			n.nre_tablekey = @evt_trailer2 AND
			getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END

  END


  /* Do not check asset notes in Invoicing (Mode 2)*/
  --If @mode <> 2 PTS 39002 CGK 9/24/2007.  We can control this using Notes Icon Selection Criteria window.
  BEGIN

   SELECT @urgent_code = ''
   If @evt_carrier = ''
	BEGIN
	   SELECT @urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM	  notes n
	   WHERE  n.ntb_table = 'carrier' AND
		  getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate()) AND
		  n.nre_tablekey IN (SELECT	lgh_carrier
				     FROM 	legheader
				     WHERE	mov_number = @mov_number)

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	  END
   ELSE
	BEGIN
	   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM		notes n
	   WHERE	n.ntb_table = 'carrier' AND
			n.nre_tablekey = @evt_carrier AND
			getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END
  END

 --ILB 15728 03/31/03
 --Only check Third party notes for Ord Entry (Mode 1), Settlements (Mode 3)
   IF (@mode = 1 or @mode = 3)
      IF @third_party = ''
	BEGIN
	   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	     FROM	notes n, orderheader
	    WHERE	ord_hdrnumber = @ord_hdrnumber AND
			n.ntb_table = 'thirdpartyprofile' AND
			n.nre_tablekey = ord_thirdpartytype1 AND
			getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())


	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END
      ELSE

	BEGIN

	SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	FROM	notes n
	WHERE	n.ntb_table = 'thirdpartyprofile' AND
		n.nre_tablekey = @third_party AND
		getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END
  --ILB 15728 03/31/03

  --If @mode <> 2
  --BEGIN

   SELECT @urgent_code = ''
   If @cmd_code = ''
	BEGIN
	   SELECT @urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM	  notes n
	   WHERE  n.ntb_table = 'commodity' AND
		  getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())AND
		  n.nre_tablekey IN (select f.cmd_code
																	from freightdetail f
																	join stops s
																	on f.stp_number = s.stp_number
																	where s.mov_number = @mov_number
																	and s.stp_type = 'DRP')

		  													/* PTS 43959 08/01/08 SGB
		  													Changed to look up cmd_code on freigthdetail and not legheader
																	(SELECT	cmd_code
																					FROM 	   legheader
																					WHERE	   mov_number = @mov_number) */

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	  END
   ELSE
	BEGIN
	   SELECT	@urgent_code = MIN(IsNull(not_urgent, 'N'))
	   FROM		notes n
	   WHERE	n.ntb_table = 'commodity' AND
			n.nre_tablekey = @cmd_code AND
			getdate() <= IsNull(DATEADD(day, @grace, n.not_expires), getdate())

	   IF @urgent_code = 'A'
		BEGIN
		   SELECT @note_count = -1
		   GOTO endprocessing
		END
	   ELSE
		BEGIN
		   IF @urgent_code = 'N'
			BEGIN
			   SELECT @note_count = 1
			END
		   ELSE IF @note_count = 0 SELECT @note_count = 0
		END

	END
  --END
END

  endprocessing:


 /*PTS 22349 CGK 7/5/2005*/
IF @customnotesicon = 'Y' AND @bitmap_id > -1000
Begin
  select @ord_notes = @note_count
End
Else
Begin
  IF @note_count = -1 SELECT @ord_notes = -1
  IF @note_count = 1 SELECT @ord_notes = 1
  IF @note_count = 0 SELECT @ord_notes = 0
End

  RETURN @ord_notes
GO
GRANT EXECUTE ON  [dbo].[d_notes_check_sp] TO [public]
GO
