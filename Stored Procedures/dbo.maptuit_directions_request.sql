SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[maptuit_directions_request] @trc_number VARCHAR(8),
                                           @lgh_number INT,
                                           @req_type CHAR(1),
                                           @gps_latitude DECIMAL(7,4),
                                           @gps_longitude DECIMAL(7,4),
                                           @cmp_idarg VARCHAR(8)
AS
DECLARE @m2reqid INT,
        @cmp_id VARCHAR(8),
        @stp_type VARCHAR(6),
        @curdate DATETIME,
        @stp_sequence INT,
        @cty_name VARCHAR(18),
        @cty_state VARCHAR(6),
        @minstp INT,
        @ctr  INT,
        @reqtype char(1),
        @process INT,
        @m2subconfig varchar(25),
        @last_leg_stp INT

SET @curdate = GETDATE()
SET @gps_longitude = @gps_longitude * -1

--PTS 24154 JLB send subconfig as well
Select @m2subconfig = left(labelfile.label_extrastring1,25)
  from tractorprofile, labelfile
 where tractorprofile.trc_number = @trc_number
   and labelfile.labeldefinition = 'MapTuitSubConfig'
   and labelfile.abbr = tractorprofile.trc_m2_subconfig

--set it back to NULL if it's UNKNOWN
if @m2subconfig = 'UNKNOWN'
  set @m2subconfig = NULL
  
IF @req_type = 'A' OR @req_type = 'P'
BEGIN
   
   EXECUTE @m2reqid = getsystemnumber 'M2REQID',''
   
   IF @req_type = 'A'
      INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                         m2reqcrtdt, m2lat, m2long, m2subcnfig)
                VALUES  (@m2reqid, 1, @trc_number, @lgh_number, 'L', @req_type, 'N', @curdate, @gps_latitude,
                         @gps_longitude, @m2subconfig)
   IF @req_type = 'P'
      INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                         m2reqcrtdt, m2lat, m2long, m2reqplant, m2subcnfig)
                VALUES  (@m2reqid, 1, @trc_number, @lgh_number, 'L', 'A', 'N', @curdate, @gps_latitude,
                         @gps_longitude, 'P', @m2subconfig)
   SET @minstp = 0
   SET @process = 0
   SET @ctr = 1
   WHILE 1=1
   BEGIN
      SELECT @minstp = Min(stp_mfh_sequence)
        FROM stops
       WHERE lgh_number = @lgh_number AND
             stp_mfh_sequence > @minstp

      IF @minstp IS NULL
         BREAK
     
      
      SELECT @cmp_id = cmp_id,
             @cty_name = cty_name,
             @cty_state = cty_state,
             @stp_type = stp_type
        FROM stops, city
       WHERE lgh_number = @lgh_number AND
             stp_mfh_sequence = @minstp AND
             stp_city = cty_code

      IF @stp_type <> 'PUP' and @stp_type <> 'DRP' and @process = 0
         CONTINUE
      ELSE
         SET @process = 1

      SET @ctr = @ctr + 1
      SET @reqtype = Substring(@stp_type, 1, 1)
      --JLB PTS 27448 do not set as viapoint the stop is the last stop of the leg
      --IF @reqtype <> 'P' and @reqtype <> 'D'
      SELECT @last_leg_stp = MAX(stp_mfh_sequence)
        FROM stops
       WHERE lgh_number = @lgh_number

      IF @reqtype <> 'P' AND @reqtype <> 'D' AND @last_leg_stp <> @minstp
      --end 27448
      BEGIN
         SET @reqtype = 'V'
			if @cmp_id = 'UNKNOWN'
           begin
             IF @req_type = 'A'
               INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                                  m2reqcrtdt, m2reqcityn, m2reqcitys, m2subcnfig)
                    VALUES (@m2reqid, @ctr, @trc_number, @lgh_number, @reqtype, @req_type, 'N', @curdate,
                            @cty_name, @cty_state, @m2subconfig)
             IF @req_type = 'P'
               INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                                  m2reqcrtdt, m2reqcityn, m2reqcitys, m2reqplant, m2subcnfig)
                    VALUES (@m2reqid, @ctr, @trc_number, @lgh_number, @reqtype, 'A', 'N', @curdate,
                            @cty_name, @cty_state, 'P', @m2subconfig)
           end
         else
           begin
             IF @req_type = 'A'
               INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                                  m2reqcrtdt, m2reqref, m2subcnfig)
                    VALUES (@m2reqid, @ctr, @trc_number, @lgh_number, @reqtype, @req_type, 'N', @curdate,
                            @cmp_id, @m2subconfig)
             IF @req_type = 'P'
               INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                                  m2reqcrtdt, m2reqref, m2subcnfig)
                    VALUES (@m2reqid, @ctr, @trc_number, @lgh_number, @reqtype, 'A', 'N', @curdate,
                            @cmp_id, @m2subconfig)
           end
      END
      ELSE
      BEGIN
		SET @reqtype = 'D'
        if @cmp_id = 'UNKNOWN'
          begin
            IF @req_type = 'A'
              INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                                 m2reqcityn, m2reqcitys, m2subcnfig)
                        VALUES  (@m2reqid, @ctr, @trc_number, @lgh_number, @reqtype, @req_type, 'N',
                                 @cty_name, @cty_state, @m2subconfig)
            IF @req_type = 'P'
              INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                                 m2reqcrtdt, m2reqcityn, m2reqcitys, m2reqplant, m2subcnfig)
                        VALUES  (@m2reqid, @ctr, @trc_number, @lgh_number, @reqtype,
                                 'A', 'N', @curdate, @cty_name, @cty_state, 'P', @m2subconfig)
          end
        else
          begin
            IF @req_type = 'A'
              INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                                 m2reqcrtdt, m2reqref, m2subcnfig)
                        VALUES  (@m2reqid, @ctr, @trc_number, @lgh_number, @reqtype,
                                 @req_type, 'N', @curdate, @cmp_id, @m2subconfig)
            IF @req_type = 'P'
              INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                                 m2reqcrtdt, m2reqref, m2reqplant, m2subcnfig)
                        VALUES  (@m2reqid, @ctr, @trc_number, @lgh_number, @reqtype,
                                 'A', 'N', @curdate, @cmp_id, 'P', @m2subconfig)
          end
      END
   END
   INSERT INTO m2reqqueue (m2qid, m2qstat) VALUES (@m2reqid, 'R')
END

IF @req_type = 'Y' OR @req_type = 'N'
BEGIN
   IF @cmp_idarg IS NULL OR rtrim(ltrim(@cmp_idarg)) = ''
   BEGIN
      SELECT @lgh_number = lgh_number
        FROM legheader_active
       WHERE lgh_tractor = @trc_number AND
             lgh_outstatus = 'STD'
      IF @lgh_number IS NULL OR @lgh_number = 0
      BEGIN
         SELECT @lgh_number = MIN(lgh_number)
           FROM legheader_active
          WHERE lgh_tractor = @trc_number AND
                lgh_outstatus = 'DSP'
      END
      IF @lgh_number IS NULL OR @lgh_number = 0
         RETURN

      EXECUTE @m2reqid = getsystemnumber 'M2REQID',''
      INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                         m2reqcrtdt, m2lat, m2long, m2subcnfig)
                VALUES  (@m2reqid, 1, @trc_number, @lgh_number, 'L', @req_type, 'N', @curdate, @gps_latitude,
                         @gps_longitude, @m2subconfig)

      SET @minstp = 0
      SET @ctr = 1
      WHILE 1=1
      BEGIN
         SELECT @minstp = Min(stp_mfh_sequence)
           FROM stops
          WHERE lgh_number = @lgh_number AND
                stp_mfh_sequence > @minstp AND
                stp_status = 'OPN'

         IF @minstp IS NULL
            BREAK
          
         SET @ctr = @ctr + 1
         SELECT @cmp_id = cmp_id,
                @cty_name = cty_name,
                @cty_state = cty_state,
                @stp_type = stp_type
           FROM stops, city
          WHERE lgh_number = @lgh_number AND
                stp_mfh_sequence = @minstp AND
                stp_city = cty_code

         SET @reqtype = Substring(@stp_type, 1, 1)
         --JLB PTS 27448 do not set as vgiapoint the stop is the last stop of the leg
         --IF @reqtype <> 'P' and @reqtype <> 'D'
         SELECT @last_leg_stp = MAX(stp_mfh_sequence)
           FROM stops
          WHERE lgh_number = @lgh_number
         IF @reqtype <> 'P' AND @reqtype <> 'D' AND @last_leg_stp <> @minstp
         --end 27448
         BEGIN
           SET @reqtype = 'V'
           if @cmp_id = 'UNKNOWN'
             begin
             INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                                m2reqcrtdt, m2reqcityn, m2reqcitys, m2subcnfig)
                  VALUES (@m2reqid, @ctr, @trc_number, @lgh_number, @reqtype, @req_type,'N', 
                          @curdate, @cty_name, @cty_state, @m2subconfig)
             end
           else
           begin
             INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                                m2reqcrtdt, m2reqref, m2subcnfig)
                  VALUES (@m2reqid, @ctr, @trc_number, @lgh_number, @reqtype, @req_type,'N', 
                          @curdate, @cmp_id, @m2subconfig)
           end
         END
         ELSE
         BEGIN
			SET @reqtype = 'D'
            if @cmp_id = 'UNKNOWN'
              begin
                INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                                   m2reqcrtdt, m2reqcityn, m2reqcitys, m2subcnfig)
                     VALUES (@m2reqid, @ctr, @trc_number, @lgh_number, @reqtype, @req_type,'N', 
                             @curdate, @cty_name, @cty_state, @m2subconfig)                
              end
            else
              begin
                INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                                   m2reqcrtdt, m2reqref, m2subcnfig)
                     VALUES (@m2reqid, @ctr, @trc_number, @lgh_number, @reqtype, @req_type,'N', 
                             @curdate, @cmp_id, @m2subconfig)
              end
            BREAK
         END
      END
      INSERT INTO m2reqqueue (m2qid, m2qstat) VALUES (@m2reqid, 'R')
   END
   ELSE
   BEGIN
      EXECUTE @m2reqid = getsystemnumber 'M2REQID',''
      INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                         m2reqcrtdt, m2lat, m2long, m2subcnfig)
           VALUES  (@m2reqid, 1, @trc_number, @lgh_number, 'L', @req_type, 'N', @curdate, @gps_latitude,
                    @gps_longitude, @m2subconfig)
      INSERT INTO m2req (m2reqid, m2reqseq, m2requnit, m2reqload, m2reqtype, m2reqcount, m2reqexpir,
                         m2reqcrtdt, m2reqref, m2subcnfig)
           VALUES (@m2reqid, 2, @trc_number, @lgh_number, 'D', @req_type,'N', @curdate, @cmp_idarg, @m2subconfig)
      INSERT INTO m2reqqueue (m2qid, m2qstat) VALUES (@m2reqid, 'R')
   END
END

GO
GRANT EXECUTE ON  [dbo].[maptuit_directions_request] TO [public]
GO
