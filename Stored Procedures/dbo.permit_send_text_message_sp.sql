SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[permit_send_text_message_sp](@p_mov_number int, @p_trc varchar(8), @p_status varchar(200) OUTPUT)
AS

   declare @v_ord_hdrnumber int,
           @v_ord_number varchar(12),
           @v_cmd_descript varchar (60),
           @v_msg_seq int,
           @v_lgh_number int,
           @v_msg_id_return int,
           @v_origin_cty_name varchar(18),
           @v_origin_state varchar(6),
           @v_dest_cty_name varchar(18),
           @v_dest_state varchar(6),
           @v_message_string varchar(255),
           @v_filterdata varchar(255),
           @v_subject varchar(255),
           @v_counter int,
           @v_pia_state char(2),
           @v_transmit_to_type varchar(6),
           @v_transmit_to varchar(30),
           @v_sp_name varchar(200),
           @v_linefeed varchar(6),
           @v_max_lines int,
           @v_line_count int,
           @v_email_body varchar(200)

--   JLB PTS 36298 get out of the procedure and return an error if no criteria was specified
   if isnull(@p_mov_number,-11) < 1
   begin
     set @p_status = 'Error Submitting message to TotalMail, No movement number was selected.'
     RETURN
   end
   --end 36298
   
   select @v_sp_name = isnull(ltrim(rtrim(gi_string1)),'')
     from generalinfo
    where gi_name = 'PermitTextMessageStoredProc'

   select @v_max_lines = 30
   
   if exists (SELECT * FROM sysobjects WHERE id = object_id(@v_sp_name) AND sysstat & 0xf = 4)
   begin
      exec @v_sp_name @p_mov_number, @p_trc, @p_status OUTPUT
      RETURN
   end
   else
   begin
      select @v_ord_hdrnumber = legheader.ord_hdrnumber,
             @v_lgh_number = legheader.lgh_number,
             @v_origin_cty_name = oc.cty_name,
             @v_origin_state = oc.cty_state,
             @v_dest_cty_name = dc.cty_name,
             @v_dest_state = dc.cty_state
        from legheader
       right outer join city oc on legheader.lgh_startcity = oc.cty_code
       right outer join city dc on legheader.lgh_endcity = dc.cty_code
       where @p_mov_number = legheader.mov_number 
         and legheader.lgh_tractor = @p_trc
      
      select @v_ord_number = ord_number
        from orderheader where ord_hdrnumber = @v_ord_hdrnumber
/*  JLB PTS 34148      
      select @v_cmd_descript = max(fgt_description)
        from freightdetail
        join stops on stops.stp_number = freightdetail.stp_number
       where freightdetail.fgt_description <> 'UNKNOWN'
         and freightdetail.fgt_description <> 'UNK'
         and stops.ord_hdrnumber = @v_ord_hdrnumber
*/
      select @v_cmd_descript = max(freightdetail.cmd_code)
        from freightdetail
        join stops on stops.stp_number = freightdetail.stp_number
       where freightdetail.fgt_sequence = 1
         and stops.ord_hdrnumber = @v_ord_hdrnumber
         and stops.ord_hdrnumber > 0
         and stops.stp_mfh_sequence = (select min(stp_mfh_sequence)
                                         from stops
                                        where ord_hdrnumber = @v_ord_hdrnumber
                                          and stp_type = 'PUP')
--end 34148
      
      select @v_filterdata = @p_trc + 'Permit' + convert(varchar(20), @v_ord_hdrnumber) + convert(varchar(20), @p_mov_number) + convert(varchar(20), @v_lgh_number)
      select @v_subject = 'Permit Info for Order ' + convert(varchar(20),@v_ord_hdrnumber)
      begin transaction
      EXEC asyncmessage_sp	@ord_hdrnumber = @v_ord_hdrnumber,
                        	@move_number = @p_mov_number,
                        	@lgh_number = @v_lgh_number,
                        	@asset = @p_trc,
                         	@assettype = '9',
                        	@formid = 0,
                        	@filterdata = @v_filterdata,
                        	@subject = @v_subject,
                        	@msgtype = 'Text',
                        	@msgkey = 'skip_data_insert',
                        	@delay = 0,
                           @msg_id_return = @v_msg_id_return OUTPUT
      
      if @@error <> 0
        begin
           rollback
           set @p_status = 'Error Submitting message to TotalMail'
           RETURN
        end
      else
        begin
          select @v_msg_seq = 1
          --begin creating the message
          select @v_message_string = UPPER('TRIP# ' + isnull(@v_ord_number,'') + '     EQUIP: ' + @p_trc)
          set @v_linefeed = 'Text' + right(('00' + (convert(varchar(2),@v_msg_seq))),2)
          exec asyncmessage_short_sp @v_msg_id_return, @v_msg_seq, @v_linefeed, @v_message_string
         if @@error <> 0
           begin
              rollback
              set @p_status = 'Error Submitting message to TotalMail'
              RETURN
           end
          select @v_msg_seq = @v_msg_seq + 1
          set @v_linefeed = 'Text' + right(('00' + (convert(varchar(2),@v_msg_seq))),2)
          select @v_message_string = UPPER('ORIGIN ' + isnull(left(@v_origin_cty_name,4) + left(@v_origin_state,4),'') + '     DEST ' + isnull(left(@v_dest_cty_name,4) + left(@v_dest_state,4),''))
          exec asyncmessage_short_sp @v_msg_id_return, @v_msg_seq, @v_linefeed, @v_message_string
         if @@error <> 0
           begin
              rollback
              set @p_status = 'Error Submitting message to TotalMail'
              RETURN
           end
          select @v_msg_seq = @v_msg_seq + 1
          set @v_linefeed = 'Text' + right(('00' + (convert(varchar(2),@v_msg_seq))),2)
          select @v_message_string = UPPER('CMDTY DESC: ' + isnull(@v_cmd_descript,''))
          exec asyncmessage_short_sp @v_msg_id_return, @v_msg_seq, @v_linefeed, @v_message_string
         if @@error <> 0
           begin
              rollback
              set @p_status = 'Error Submitting message to TotalMail'
              RETURN
           end
          select @v_msg_seq = @v_msg_seq + 1
          set @v_linefeed = 'Text' + right(('00' + (convert(varchar(2),@v_msg_seq))),2)
          select @v_message_string = UPPER('STATES ORDERED:')
          exec asyncmessage_short_sp @v_msg_id_return, @v_msg_seq, @v_linefeed, @v_message_string
         if @@error <> 0
           begin
              rollback
              set @p_status = 'Error Submitting message to TotalMail'
              RETURN
           end
         --loop thru the permits and generate a line for each to where they where transmitted to
         select @v_counter = min(p_id)
           from permits
          where permits.mov_number = @p_mov_number
             or permits.lgh_number = @v_lgh_number
         while @v_counter is not null
           begin
             select @v_msg_seq = @v_msg_seq + 1
             select @v_pia_state = permit_issuing_authority.st_abbr,
                    @v_transmit_to_type = permits.p_transmit_to_type,
                    @v_transmit_to = ltrim(rtrim(permits.p_transmit_to))
               from permit_issuing_authority
               join permit_master on permit_issuing_authority.pia_id = permit_master.pia_id
               join permits on permit_master.pm_id = permits.pm_id
                and permits.p_id = @v_counter
             select @v_message_string = UPPER(isnull('   ' + @v_pia_state + '/','') +  isnull(@v_transmit_to, ''))
             --if it is being transmitted to a truckstop also include the city
             if @v_transmit_to_type = 'TRCSTP'
               select @v_message_string = UPPER(isnull('   ' + @v_message_string + cty_name + ', ' + cty_state, @v_message_string))
                 from city
                 join truckstops on truckstops.ts_cty = city.cty_code
                where truckstops.ts_code = @v_transmit_to
             set @v_linefeed = 'Text' + right(('00' + (convert(varchar(2),@v_msg_seq))),2)
             exec asyncmessage_short_sp @v_msg_id_return, @v_msg_seq, @v_linefeed, @v_message_string
             if @@error <> 0
               begin
                  rollback
                  set @p_status = 'Error Submitting message to TotalMail'
                  RETURN
               end
             select @v_line_count = isnull(@v_line_count,0) + 1
             if @v_line_count > @v_max_lines
             begin
               rollback
               set @p_status = 'Error Submitting message to TotalMail, maximum line count (' + convert(varchar(20), @v_max_lines) + ') was exceeded.'
               --this is not setup to email but the infrastructure is here if you want it to be
               set @v_email_body = 'Error Submitting Permitting message to TotalMail, maximum line count (' + convert(varchar(20), @v_max_lines) + ') was exceeded.' + char(10)
               set @v_email_body = 'OrderHeader Number: ' + convert(varchar(20), isnull(@v_ord_hdrnumber,'NULL')) + char(10)
               set @v_email_body = isnull(@v_email_body,'') + 'Order Number: ' + convert(varchar(20), isnull(@v_ord_number,'NULL')) + char(10)
               set @v_email_body = isnull(@v_email_body,'') + 'Leg Number: ' + convert(varchar(20), isnull(@v_lgh_number,'NULL')) + char(10)
               set @v_email_body = isnull(@v_email_body,'') + 'Move Number: ' + convert(varchar(20), isnull(@p_mov_number,'NULL')) + char(10)
               set @v_email_body = isnull(@v_email_body,'') + 'Tractor Number: ' + convert(varchar(20), isnull(@p_trc,'NULL')) + char(10)
               set @v_email_body = isnull(@v_email_body,'') + 'User: ' + convert(varchar(20), isnull(suser_sname(),'NULL')) + char(10)
               RETURN
             end
			 
             select @v_counter = min(p_id)
               from permits
              where (permits.mov_number = @p_mov_number
                 or permits.lgh_number = @v_lgh_number)
                and p_id > @v_counter
           end
         --if it got this far all the inserts worked
         COMMIT
      --return message to the application
         set @p_status = 'Message Submitted to TotalMail for Delivery'
   end
end

GO
GRANT EXECUTE ON  [dbo].[permit_send_text_message_sp] TO [public]
GO
