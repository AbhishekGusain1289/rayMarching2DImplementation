import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import GUI from 'lil-gui'
import testVertexShader from './shaders/test/vertex.glsl'
import testFragmentShader from './shaders/test/fragment.glsl'
import { EffectComposer } from 'three/examples/jsm/Addons.js'
import { RenderPass } from 'three/examples/jsm/Addons.js'
import { ShaderPass } from 'three/examples/jsm/Addons.js'

/**
 * Base
 */
// Debug
const gui = new GUI()
gui.hide()
const debugObject = {}
debugObject.ColorA = '#003cf0'
debugObject.ColorB = '#ffffff'

// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()

/**
 * Test mesh
 */
// Geometry
const geometry = new THREE.PlaneGeometry(1, 1, 32, 32)



// Mesh
// const mesh = new THREE.Mesh(geometry, material)
// scene.add(mesh)

/**
 * Sizes
 */
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight
}

window.addEventListener('resize', () =>
{
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

    noiseShader.uniforms.uResolution.value = new THREE.Vector2(sizes.width, sizes.height)
})

/**
 * Camera
 */
// Base camera
const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height, 0.1, 100)
camera.position.set(0.25, - 0.25, 1)
scene.add(camera)

// Controls
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas
})
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

// Material
const noiseShader = new THREE.ShaderMaterial({
    vertexShader: testVertexShader,
    fragmentShader: testFragmentShader,
    side: THREE.DoubleSide,
    transparent: true,
    uniforms: {
        tDiffuse: {value: null},
        uTime: {value : 0},
        uColorA: {value: new THREE.Color(debugObject.ColorA)},
        uColorB: {value: new THREE.Color(debugObject.ColorB)},
        uResolution: {value: new THREE.Vector2(sizes.width, sizes.height)},
        uRotationAngle: {value: 3}
    }
})



/**
 * Shader Stuff *******************************************************************************
 */

const composer = new EffectComposer(renderer)
const renderPass = new RenderPass(scene, camera)

const noisePass = new ShaderPass(noiseShader)

composer.addPass(renderPass)
composer.addPass(noisePass)






gui.add(noiseShader.uniforms.uRotationAngle, "value", -180, 180, 0.01).name("uRotationAngle")



/**
 * Animate
 */
const clock = new THREE.Clock()
const tick = () =>
{
    // Update controls
    const elapsedTime = clock.getElapsedTime()
    controls.update()

    noisePass.uniforms.uTime.value = elapsedTime

    composer.render()

    // Render
    // renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()
