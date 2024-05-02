//============module=========//
const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');
const cookieParser = require('cookie-parser');
const logger = require('morgan');
const mysql = require('mysql');
const bcrypt = require('bcrypt');
const session = require('express-session');
const app = express();
app.use(express.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(logger('dev'));
app.use(express.json());
//==============connectDB=============//
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'last_project'
});
connection.connect((err) => {
    if (err) throw err;
    console.log('Connected to MySQL database');
});
//==============setup folder================//
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));
//=======session=========//
app.use(session({
    secret: 'your-secret-key',
    resave: false,
    saveUninitialized: true
}));

//============== view engine setup ==================//
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));

// Middleware สำหรับการแปลงข้อมูลที่ส่งมาเป็น JSON
app.use(express.json());

//============route of student============//
app.get('/register', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'register.html'));
});
app.get('/', function (req, res) {
    if (req.session.username) {
        res.redirect('/student_booking.html');
    } else {
        res.redirect('/login');
    }
});

// Middleware เพื่อตรวจสอบบทบาทของผู้ใช้
function checkUserRole(req, res, next) {
    const allowedRoles = ['student', 'staff', 'lecture'];
    if (req.session.role && allowedRoles.includes(req.session.role)) {
        // ถ้าผู้ใช้มีบทบาทที่อนุญาตให้เข้าถึงหน้านี้
        next();
    } else {
        res.status(403).send('Permission denied');
    }
}

//============register API all users============//
app.post('/register', async (req, res) => {
    try {
        const { username, email, password } = req.body;
        if (!username || !email || !password) {
            return res.status(400).send("กรุณากรอกข้อมูลให้ครบถ้วน");
        }
        let role;
        if (username.toLowerCase().includes('student')) {
            role = 'student';
        } else if (username.toLowerCase().includes('staff')) {
            role = 'staff';
        } else if (username.toLowerCase().includes('lecture')) {
            role = 'lecture';
        } else {
            return res.status(400).send("ไม่สามารถกำหนด role ได้จาก username");
        }
        const checkDuplicateQuery = `SELECT * FROM users WHERE username = ? OR email = ?`;
        const duplicateExists = await new Promise((resolve, reject) => {
            connection.query(checkDuplicateQuery, [username, email], (err, results) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(results.length > 0);
                }
            });
        });

        if (duplicateExists) {
            return res.status(400).send("มี username หรือ email นี้ใช้งานอยู่แล้ว");
        }
        const hashedPassword = await bcrypt.hash(password, 10);

        const insertUserQuery = `INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)`; // เพิ่มฟิลด์ role
        await new Promise((resolve, reject) => {
            connection.query(insertUserQuery, [username, email, hashedPassword, role], (err, result) => {
                if (err) {
                    reject(err);
                } else {
                    resolve();
                }
            });
        });
        req.session.username = username;
        res.redirect('/login');
    } catch {
        res.status(500).send("มีข้อผิดพลาดในการลงทะเบียน");
    }
});

//============route login============//
app.get('/login', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'login.html'));
});
//============login API all users============//
app.post('/login', async (req, res) => {
    try {
        const { username, password } = req.body;
        if (!username || !password) {
            return res.status(400).send("กรุณากรอกชื่อผู้ใช้และรหัสผ่าน");
        }
        const getUserQuery = 'SELECT * FROM users WHERE username = ?';
        connection.query(getUserQuery, [username], async (error, results) => {
            if (error) {
                console.error('Error during login:', error);
                return res.status(500).send('Internal server error');
            }
            if (results.length === 0) {
                return res.sendStatus(401);
            }
            const user = results[0];
            const passwordMatch = await bcrypt.compare(password, user.password);
            if (!passwordMatch) {
                return res.sendStatus(401);
            }
            req.session.username = username;

            // ตรวจสอบบทบาทของผู้ใช้และทำการ redirect ไปยังหน้าที่เหมาะสม
            if (username.toLowerCase().includes('student')) {
                res.redirect('/student_booking.html');
            } else if (username.toLowerCase().includes('staff')) {
                res.redirect('/staff_dashboard.html');
            } else if (username.toLowerCase().includes('lecture')) {
                res.redirect('/lecture_dashboard.html');
            }
        });
    } catch {
        res.status(500).send("มีข้อผิดพลาดในการเข้าสู่ระบบ");
    }
});

//============logout API all users============//
app.get('/logout', (req, res) => {
    try {
        req.session.destroy(err => {
            if (err) {
                return res.status(500).send("มีข้อผิดพลาดในการออกจากระบบ");
            }
            res.redirect('/');
        });
    } catch {
        res.status(500).send("มีข้อผิดพลาดในการออกจากระบบ");
    }
});

function requireLogin(req, res, next) {
    if (req.session.username) {
        next();
    } else {
        res.status(401).send('Unauthorized');
    }
}
//=================browseroomLists================//
app.get('/browseroomLists.html', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'browseroomLists.html'));
});
// API endpoint for fetching time slots
app.get('/api/browseroomLists', (req, res) => {
    connection.query('SELECT * FROM time_slot', (err, results) => {
        if (err) {
            console.error('Error:', err);
            res.status(500).json({ error: 'An error occurred while fetching room lists.' });
        } else {
            res.status(200).json(results);
        }
    });
});




//=================homepage================//
app.get('/homepage.html', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'homepage.html'));
});

//=================student================//
//===============student API================//
//===============student route================//
app.get('/student_booking.html', requireLogin, (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'student_booking.html'));
});
app.post('/api/bookings', (req, res) => {
    const { staff_id, roomname, room_status, slot_id, reason, status, approver, user_id } = req.body;

    const sql = `INSERT INTO bookings (staff_id, roomname, room_status, slot_id, reason, status, approver, user_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`;
    const values = [staff_id, roomname, room_status, slot_id, reason, status, approver, user_id];

    connection.query(sql, values, (err, result) => {
        if (err) {
            res.status(500).send('Error inserting data into database');
            throw err;
        }
        res.status(200).send('Booking data inserted successfully');
    });
});

//======================student status====================//
app.get('/student_status.html', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'student_status.html'));
});
// API endpoint for getting bookings
app.get('/api/bookings', (req, res) => {
    connection.query('SELECT * FROM bookings', (err, results) => {
        if (err) {
            console.error('Error:', err);
            res.status(500).json({ error: 'An error occurred while fetching bookings.' });
        } else {
            res.status(200).json(results);
        }
    });
});


// API endpoint for updating booking status
app.put('/api/bookings/:id', (req, res) => {
    const { id } = req.params;
    const { status, approver } = req.body;
    connection.query('UPDATE bookings SET status = ?, approver = ? WHERE id = ?', [status, approver, id], (err, result) => {
        if (err) {
            console.error('Error:', err);
            return res.status(500).json({ error: 'An error occurred while updating booking status.' });
        } else {
            console.log('Booking status updated successfully');
            res.redirect('/student_status.html');
        }
    });
});
// API endpoint for student booking status
app.get('/api/student-booking-status/:studentId', (req, res) => {
    const studentId = req.params.studentId;

    connection.query('SELECT b.*, bh.approver, bh.status FROM bookings b JOIN booking_history bh ON b.id = bh.booking_id WHERE b.student_id = ?', studentId, (err, results) => {
        if (err) {
            console.error('Error:', err);
            res.status(500).json({ error: 'An error occurred while fetching booking status.' });
        } else {
            res.status(200).json(results);
        }
    });
});

// API endpoint for retrieving room status from student_status.html+
app.get('/api/room-status-from-student', (req, res) => {
    const roomStatusData = getRoomStatusFromStudent();

    res.status(200).json(roomStatusData);
});

//======================student history====================//
app.get('/student_his.html', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'student_his.html'));
});
// API endpoint for fetching booking history
app.get('/api/booking-history', (req, res) => {
    connection.query('SELECT * FROM bookings', (err, results) => {
        if (err) {
            console.error('Error:', err);
            res.status(500).json({ error: 'An error occurred while fetching booking history.' });
        } else {
            res.status(200).json(results);
        }
    });
});
//=================staff================//
//===============staff API================//
//===============staff route================//
app.get('/staff_manage.html', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'staff_manage.html'));
});
app.get('/staff_dashboard.html', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'staff_dashboard.html'));
});
app.get('/staff_status.html', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'staff_status.html'));
});
// API endpoint for fetching booking details by booking ID
app.get('/api/booking-details/:id', (req, res) => {
    const bookingId = req.params.id;

    connection.query('SELECT * FROM bookings WHERE id = ?', bookingId, (err, results) => {
        if (err) {
            console.error('Error:', err);
            res.status(500).json({ error: 'An error occurred while fetching booking details.' });
        } else {
            if (results.length > 0) {
                res.status(200).json(results[0]);
            } else {
                res.status(404).json({ message: 'Booking not found' });
            }
        }
    });
});
app.get('/staff_manage', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'staff_manage.html'));
});

app.get('/staff_history.html', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'staff_history.html'));
});

// app.get('/staff_addingroom.html', (req, res) => {
//     res.sendFile(path.join(__dirname, 'views', 'staff_addingroom.html'));
// });

// app.get('/staff_edittionroom.html', (req, res) => {
//     res.sendFile(path.join(__dirname, 'views', 'staff_edittionroom.html'));
// });

//=================lecture================//
//===============lecture API================//
//===============lecture route================//
// app.get('/lecture_booking_status', (req, res) => {
//     res.sendFile(path.join(__dirname, 'views', 'lecture_booking_status.html'));
// });

app.get('/lecture_dashboard.html', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'lecture_dashboard.html'));
});

app.get('/lecture_history.html', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'lecture_history.html'));
});

app.get('/lecture_bookingrequest.html', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'lecture_bookingrequest.html'));
});
// API endpoint for updating booking status by lecture
app.put('/api/bookings/:id', (req, res) => {
    const { id } = req.params;
    const { status, approver } = req.body;
    if (req.user.role !== 'lecture') {
        return res.status(403).json({ error: 'Only lecture can update booking status' });
    }
    if (status !== 'pending') {
        return res.status(400).json({ error: 'Only "pending" status can be updated' });
    }
    connection.query('UPDATE bookings SET status = ?, approver = ? WHERE id = ?', [status, approver, id], (err, result) => {
        if (err) {
            console.error('Error:', err);
            res.status(500).json({ error: 'An error occurred while updating booking status.' });
        } else {
            console.log('Booking status updated successfully');
            res.status(200).json({ message: 'Booking status updated successfully' });
            connection.query('INSERT INTO booking_history (booking_id, approver, status) VALUES (?, ?, ?)', [id, approver, status], (err, result) => {
                if (err) {
                    console.error('Error:', err);
                } else {
                    console.log('Booking history recorded successfully');
                }
            });
        }
    });
});
// API endpoint for updating booking status by lecture
app.put('/api/bookings/:id/confirm', (req, res) => {
    const { id } = req.params;
    const { status, approver } = req.body;

    // Only update booking status when requested status is 'accepted' or 'rejected'
    if (status !== 'accepted' && status !== 'rejected') {
        return res.status(400).json({ error: 'Status can only be "accepted" or "rejected"' });
    }

    // Define the new room status based on the booking status
    const roomStatus = status === 'accepted' ? 'reserved' : 'available';

    connection.query('UPDATE bookings SET status = ?, approver = ?, room_status = ? WHERE id = ?', [status, approver, roomStatus, id], (err, result) => {
        if (err) {
            console.error('Error:', err);
            res.status(500).json({ error: 'An error occurred while updating booking status.' });
        } else {
            console.log('Booking status updated successfully');
            res.status(200).json({ message: 'Booking status updated successfully' });

            // If status is accepted, also insert into booking confirmation table
            if (status === 'accepted') {
                connection.query('INSERT INTO booking_confirmation (booking_id, approver, status) VALUES (?, ?, ?)', [id, approver, status], (err, result) => {
                    if (err) {
                        console.error('Error:', err);
                    } else {
                        console.log('Booking confirmation recorded successfully');
                    }
                });
            }
        }
    });
});


//===============student_status.html and student_his.html================//
function updateStudentStatusAndHistory(bookingId, status) {
    // Update status in student_status.html
    const studentStatusElement = document.getElementById(`status_${bookingId}`);
    if (studentStatusElement) {
        studentStatusElement.textContent = status.charAt(0).toUpperCase() + status.slice(1);
    }

    // Update status in student_his.html
    const studentHistoryElement = document.getElementById(`status_${bookingId}`);
    if (studentHistoryElement) {
        studentHistoryElement.textContent = status.charAt(0).toUpperCase() + status.slice(1);
    }
}




const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port  ${PORT}`);
});
