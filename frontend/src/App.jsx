import { useMemo, useState } from 'react'
import './App.css'

function App() {
  const [hello, setHello] = useState(null)
  const [time, setTime] = useState(null)
  const [env, setEnv] = useState(null)
  const [health, setHealth] = useState(null)
  const [echoInput, setEchoInput] = useState(`{"message":"test"}`)
  const [echoOutput, setEchoOutput] = useState(null)
  const [lastError, setLastError] = useState('')

  const pretty = useMemo(() => {
    return {
      hello: hello ? JSON.stringify(hello, null, 2) : '',
      time: time ? JSON.stringify(time, null, 2) : '',
      env: env ? JSON.stringify(env, null, 2) : '',
      health: health ? JSON.stringify(health, null, 2) : '',
      echoOutput: echoOutput ? JSON.stringify(echoOutput, null, 2) : '',
    }
  }, [hello, time, env, health, echoOutput])

  async function getJson(path, init) {
    setLastError('')
    const res = await fetch(path, init)
    const text = await res.text()
    let data
    try {
      data = text ? JSON.parse(text) : null
    } catch {
      data = { raw: text }
    }
    if (!res.ok) {
      const msg = `HTTP ${res.status} ${res.statusText} from ${path}`
      const err = new Error(msg)
      err.data = data
      throw err
    }
    return data
  }

  async function refreshHello() {
    try {
      setHello(await getJson('/api/hello'))
    } catch (e) {
      setLastError(`${e.message}${e.data ? `\n${JSON.stringify(e.data, null, 2)}` : ''}`)
    }
  }

  async function refreshTime() {
    try {
      setTime(await getJson('/api/time'))
    } catch (e) {
      setLastError(`${e.message}${e.data ? `\n${JSON.stringify(e.data, null, 2)}` : ''}`)
    }
  }

  async function refreshEnv() {
    try {
      setEnv(await getJson('/api/env'))
    } catch (e) {
      setLastError(`${e.message}${e.data ? `\n${JSON.stringify(e.data, null, 2)}` : ''}`)
    }
  }

  async function refreshHealth() {
    try {
      setHealth(await getJson('/actuator/health'))
    } catch (e) {
      setLastError(`${e.message}${e.data ? `\n${JSON.stringify(e.data, null, 2)}` : ''}`)
    }
  }

  async function sendEcho() {
    setLastError('')
    let body
    try {
      body = JSON.parse(echoInput)
    } catch {
      setLastError('Echo body must be valid JSON.')
      return
    }
    try {
      setEchoOutput(
        await getJson('/api/echo', {
          method: 'POST',
          headers: { 'content-type': 'application/json' },
          body: JSON.stringify(body),
        }),
      )
    } catch (e) {
      setLastError(`${e.message}${e.data ? `\n${JSON.stringify(e.data, null, 2)}` : ''}`)
    }
  }

  return (
    <div className="page">
      <header className="header">
        <div className="title">Spring Boot Demo App</div>
        <div className="subtitle">React UI + /api + Actuator health</div>
      </header>

      {lastError ? (
        <div className="error">
          <div className="errorTitle">Error</div>
          <pre className="mono">{lastError}</pre>
        </div>
      ) : null}

      <div className="grid">
        <section className="card">
          <div className="cardTitle">API: Hello</div>
          <div className="actions">
            <button onClick={refreshHello}>GET /api/hello</button>
          </div>
          <pre className="mono">{pretty.hello}</pre>
        </section>

        <section className="card">
          <div className="cardTitle">API: Time</div>
          <div className="actions">
            <button onClick={refreshTime}>GET /api/time</button>
          </div>
          <pre className="mono">{pretty.time}</pre>
        </section>

        <section className="card">
          <div className="cardTitle">API: Env (safe subset)</div>
          <div className="actions">
            <button onClick={refreshEnv}>GET /api/env</button>
          </div>
          <pre className="mono">{pretty.env}</pre>
        </section>

        <section className="card">
          <div className="cardTitle">Actuator: Health</div>
          <div className="actions">
            <button onClick={refreshHealth}>GET /actuator/health</button>
          </div>
          <pre className="mono">{pretty.health}</pre>
        </section>

        <section className="card cardWide">
          <div className="cardTitle">API: Echo</div>
          <div className="actions">
            <button onClick={sendEcho}>POST /api/echo</button>
          </div>
          <div className="twoCol">
            <div>
              <div className="label">Request JSON</div>
              <textarea
                className="textarea mono"
                value={echoInput}
                onChange={(e) => setEchoInput(e.target.value)}
                rows={8}
              />
            </div>
            <div>
              <div className="label">Response</div>
              <pre className="mono">{pretty.echoOutput}</pre>
            </div>
          </div>
        </section>
      </div>

      <footer className="footer mono">
        Tip: for local dev run React on <code>http://localhost:5173</code> and Spring Boot on{' '}
        <code>http://localhost:8080</code>.
      </footer>
    </div>
  )
}

export default App
